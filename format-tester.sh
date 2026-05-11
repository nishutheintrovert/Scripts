#!/usr/bin/env bash

generate_messy_file() {
    local target_file="$1"

    echo "Generating messy file: $target_file"

    # \x20 = space | \t = tab | \n = LF | \r\n = CRLF

    printf "LF line\n" >"$target_file"
    printf "LF line\x20\x20\x20\x20\x20\x20\n" >>"$target_file"
    printf "\r\n" >>"$target_file"
    printf "\n" >>"$target_file"
    printf "\r\n" >>"$target_file"
    printf "\n" >>"$target_file"
    printf "\r\n" >>"$target_file"
    printf "\n" >>"$target_file"
    printf "CRLF line\x20\x20\x20\x20\x20\x20\x20\x20\r\n" >>"$target_file"
    printf "CRLF line\x20\x20\x20\x20\x20\x20\r\n" >>"$target_file"
    printf "Line with tabs\t\t\tto test conversion\n" >>"$target_file"
    printf "Trailing tabs test\t\t\n" >>"$target_file"
    printf "oneanr\x20\x20soiente\x20aste\x20\x20\x20anot\x20oinaeirst\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20" >>"$target_file"
    printf "Another LF\x20\x20\x20\x20\x20\x20\n" >>"$target_file"
    printf "CRLF line\r\n" >>"$target_file"
    printf "\r\n" >>"$target_file"
    printf "\n" >>"$target_file"
    printf "\r\n" >>"$target_file"
    printf "\n" >>"$target_file"
    printf "\r\n" >>"$target_file"
    printf "\n" >>"$target_file"
}

generate_messy_file "test-text.txt"
generate_messy_file "test-shell-script.sh"
generate_messy_file ".test-dotfile"
generate_messy_file "example.test-dotfile"
generate_messy_file "test-no-extension-file"

echo "Done! Test environment ready."
