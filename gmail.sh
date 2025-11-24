#!/bin/bash

# Easier oneliner
# "/c/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe" https://mail.google.com/mail/u/{0..9}/#inbox

# Number of Gmail accounts to open
NUM_ACCOUNTS=10

# Loop through each account index and open the corresponding Gmail inbox
for ((i = 0; i < NUM_ACCOUNTS; i++)); do
    URL="https://mail.google.com/mail/u/$i/#inbox"
    echo "Opening $URL"
    # Start all URLs in one go
    start "$URL" &
done

wait # optional: wait for all background processes
