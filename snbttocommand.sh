#!/bin/bash
# Reads villager.txt with multiple SNBT lines, stops at first empty line
# Appends summon commands for each villager back into villager.txt

set -euo pipefail

FILE="/d/desktop/Villager.txt"

if [[ ! -f "$FILE" ]]; then
    echo "Error: $FILE not found in script folder."
    exit 1
fi

# Create a temp file for summon commands
TMP=$(mktemp)

while IFS= read -r line; do
    # Stop if we hit the first empty line
    [[ -z "$line" ]] && break

    vd=$(echo "$line" | perl -0777 -ne '
    sub extract_block {
      my ($s, $key) = @_;
      my $kp = index($s, $key);
      return "" if $kp == -1;
      my $colon = index($s, ":", $kp);
      return "" if $colon == -1;
      my $brace = index($s, "{", $colon);
      return "" if $brace == -1;
      my $i = $brace;
      my $len = length($s);
      my $depth = 0;
      for (; $i < $len; $i++) {
        my $c = substr($s, $i, 1);
        if ($c eq "{") { $depth++; }
        elsif ($c eq "}") {
          $depth--;
          if ($depth == 0) {
            my $blk = substr($s, $kp, $i - $kp + 1);
            $blk =~ s/^\s+|\s+$//g;
            $blk =~ s/[ \t\r\n]+/ /g;
            print $blk;
            last;
          }
        }
      }
    }
    extract_block($_, "VillagerData");
  ')

    of=$(echo "$line" | perl -0777 -ne '
    sub extract_block {
      my ($s, $key) = @_;
      my $kp = index($s, $key);
      return "" if $kp == -1;
      my $colon = index($s, ":", $kp);
      return "" if $colon == -1;
      my $brace = index($s, "{", $colon);
      return "" if $brace == -1;
      my $i = $brace;
      my $len = length($s);
      my $depth = 0;
      for (; $i < $len; $i++) {
        my $c = substr($s, $i, 1);
        if ($c eq "{") { $depth++; }
        elsif ($c eq "}") {
          $depth--;
          if ($depth == 0) {
            my $blk = substr($s, $kp, $i - $kp + 1);
            $blk =~ s/^\s+|\s+$//g;
            $blk =~ s/[ \t\r\n]+/ /g;
            print $blk;
            last;
          }
        }
      }
    }
    extract_block($_, "Offers");
  ')

    if [[ -n "$vd" && -n "$of" ]]; then
        echo "/summon villager ~ ~ ~ {$vd,$of}" >>"$TMP"
    fi
done <"$FILE"

# Append a separating newline + all commands at once
echo "" >>"$FILE"
cat "$TMP" >>"$FILE"
rm "$TMP"
