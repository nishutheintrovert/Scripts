#!/bin/bash

# Number of Gmail accounts to open
NUM_ACCOUNTS=9

# Loop through each account index and open the corresponding Gmail inbox
for ((i = 0; i < NUM_ACCOUNTS; i++)); do
    URL="https://mail.google.com/mail/u/$i/#inbox"
    echo "Opening $URL"
    start "$URL"
done
