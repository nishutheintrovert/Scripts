#!/usr/bin/env bash

#    Author    : Nishikant Kanunje
#    Date    : 19/05/2026
#    Purpose    : Find discrepancies between extract-ids-from-config-folders-array.txt (Config.json folder array extract) and wallpapers directory (wallpapers.txt extract)

awk '
    # 1. Load extract-ids-from-config.folders-array.txt IDs into memory (List A)
    FILENAME == "./extract-ids-from-config-folders-array.txt" {
        id = $0
        if (id != "" && id != "D:") {
            log_ids[id] = 1
        }
        next
    }

    # 2. Load myprojects.txt IDs into memory (List B)
    FILENAME == "./wallpapers.txt" {
        n = split($0, parts, "=")
        id = parts[n]
        if (id != "") {
            proj_ids[id] = 1
        }
        next
    }

    # 3. The Discrepancy Check
    END {
        # Check List A against List B
        print "=== extract-ids-from-config-folders-array.txt ==="
        for (id in log_ids) {
            if (!(id in proj_ids)) {
                print id
            }
        }

        # Check List B against List A
        print "\n=== wallpapers.txt ==="
        for (id in proj_ids) {
            if (!(id in log_ids)) {
                print id
            }
        }
    }
' ./extract-ids-from-config-folders-array.txt ./wallpapers.txt >discrepancies.txt
