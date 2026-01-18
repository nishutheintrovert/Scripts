#!/usr/bin/env bash

script_name=$(basename "${0}")
output_file="${script_name%.*}.json"

region="ap"
platform="pc"
account="itsme/NISHU"

curl -L \
    --url "https://api.henrikdev.xyz/valorant/v2/mmr-history/${region}/${platform}/${account}" \
    --header "Authorization: ${HENRIKDEV_ADVANCED_KEY}" \
    --header 'Accept: application/json' \
    -o "${output_file}"
