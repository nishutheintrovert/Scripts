#!/usr/bin/env bash

#	Author	: Nishikant Kanunje
#	Date	: 14/11/2026
#	Purpose	: Prints ownership, permissions and SELinux context of given package directory contents

# ANSI color codes
RED='\033[0;31m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
RESET='\033[0m'

# Target package
PKG="com.wordsmobile.gunship"

# Print the terminal prompt
prompt() {
    echo -e "${MAGENTA}$PWD ${CYAN}(main)${RESET}"
}

# Helper function to print a command and then execute it
run_and_log() {
    local cmd_string="$1"

    prompt
    printf "\$ %s\n" "$cmd_string"

    eval "$cmd_string"
}

# Commands
case "$1" in
    debug)
        cmd1="adb shell run-as $PKG ls -ldZ //data/data/$PKG"
        cmd2="adb shell run-as $PKG ls -lZ //data/data/$PKG"
        cmd3="adb shell run-as $PKG ls -lZ //data/data/$PKG/shared_prefs"
        ;;
    root)
        cmd1="adb shell su -c ls -lZ //data/data | grep \"$PKG\""
        cmd2="adb shell su -c ls -lZ //data/data/$PKG"
        cmd3="adb shell su -c ls -lZ //data/data/$PKG/shared_prefs"
        ;;
    *)
        echo -e "${RED}Usage: $0 {debug|root}${RESET}" >&2
        exit 1
        ;;
esac

# Run the block, display color in terminal, but strip codes before clip.exe
{
    run_and_log "$cmd1"
    run_and_log "$cmd2"
    run_and_log "$cmd3"
} | tee >(sed -E 's/\x1B\[[0-9;]*[a-zA-Z]//g' | clip.exe)
