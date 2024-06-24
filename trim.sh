#!/bin/bash

find . -type f ! -path '*/.git/*' -exec file --mime-type {} + | grep -E 'text/' | cut -d: -f1 | tr '\n' '\0' | xargs -0 -P 4 -n 10 sed -i 's/[ \t]\+$//'
