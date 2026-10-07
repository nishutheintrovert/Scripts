#!/usr/bin/env bash

for i in {1..60}; do
    curl -s https://api.github.com/repos/nishutheintrovert/Scripts >/dev/null
    echo "Request $i"
done
read -rsn1
