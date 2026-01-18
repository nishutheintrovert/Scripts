#!/usr/bin/env bash

script_name=$(basename "${0}")
output_file="${script_name%.*}.json"

account="itsme/NISHU"

curl -L \
    --url "https://api.henrikdev.xyz/valorant/v2/account/${account}" \
    --header "Authorization: ${HENRIKDEV_ADVANCED_KEY}" \
    --header 'Accept: Application/json' \
    -o "${output_file}"
