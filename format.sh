#!/bin/bash

# Trim.sh
echo "Trimming Whitespaces at end of lines"
find . -type f ! -path '*/.git/*' -print0 | xargs -0 -r file --mime-encoding | grep -v 'binary' | cut -d: -f1 | tr '\n' '\0' | xargs -0 -r -P 4 -n 10 sed -i 's/[ \t]\+$//'

# EOF.sh
echo "Trimming empty newlines at end of file"
echo "Adding trailing newline at end of file"
find . -type f ! -path '*/.git/*' -print0 | xargs -0 -r file --mime-encoding | grep -v 'binary' | cut -d: -f1 | tr '\n' '\0' | xargs -0 -r -P 4 -n 10 sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' -e '$a\'

# Unix2dos
echo "Converting files to CRLF line endings"
find . -type f ! -path '*/.git/*' -print0 | xargs -0 -r file --mime-encoding | grep -v 'binary' | cut -d: -f1 | tr '\n' '\0' | xargs -0 -r -P 4 -n 10 unix2dos >/dev/null 2>&1

# Dos2unix
echo "Converting Unix based files to LF line endings"
find . ! -path '*/.git/*' -type f \( -name "*.bash" -o -name "*.fish" -o -name "*.ksh" -o -name "*.sh" -o -name "*.zsh" \) -print0 | xargs -0 -r -P 4 -n 10 dos2unix >/dev/null 2>&1

echo -e "\033[0;92mDone!\033[0m"
