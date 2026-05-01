#!/bin/bash

# Define your browser path
BROWSER="/c/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe"

# Bash expands {0..9} into 10 separate URLs automatically
"$BROWSER" https://mail.google.com/mail/u/{0..4}/#inbox >/dev/null 2>&1 &
disown
