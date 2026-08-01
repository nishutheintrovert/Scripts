#	Author	: Nishikant Kanunje
#	Date	: 01/08/2026
#	Purpose	: Open subscribed wallpaper folders from wallpaper engine installation path

#!/usr/bin/env bash

trap 'exit 130' INT

count=0
find "C:\Program Files (x86)\Steam\steamapps\workshop\content\431960" -mindepth 1 -maxdepth 1 -type d |
    while read -r f; do
        explorer.exe "${f//\//\\}" &

        ((count++))
        if ((count % 10 == 0)); then
            printf '\e[2t'

            echo -n "Booted 10 windows. Press [Spacebar] to continue, [q] to quit: "

            while true; do
                if ! IFS= read -rsn1 key </dev/tty; then
                    echo -e "\nTerminal disconnected or read failed. Breaking loop!"
                    break 2
                fi

                if [[ "$key" == " " ]]; then
                    echo ""
                    break
                elif [[ "$key" == "q" || "$key" == "Q" ]]; then
                    echo -e "\nQuit key pressed. Breaking loop."
                    break 2
                fi
            done
        fi
    done
