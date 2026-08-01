#	Author	: Nishikant Kanunje
#	Date	: 01/08/2026
#	Purpose	: Opens URL's from wallpaper.txt

#!/usr/bin/env bash

completed_count=0
line_num=0

while IFS= read -r -u 3 url; do
    ((line_num++))

    if ((line_num <= completed_count)); then
        continue
    fi

    [[ -z "$url" ]] && continue

    echo "Opening wallpaper #$line_num..."

    start "$url"
    count=0

    while ! tasklist //v //fo list | grep -i "Steam Workshop::" >/dev/null; do
        if [ "$count" -ge 16 ]; then
            echo "Timeout reached."
            break
        fi

        ((count++))
        read -t 0.3
    done

    while tasklist.exe //v //fo list | grep -Ei "Steam Workshop::|Steam Community :: Error" >/dev/null; do
        read -t 0.3
    done

    echo "-----------------------------------"

done 3<"wallpapers.txt"
