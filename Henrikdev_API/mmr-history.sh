#!/usr/bin/env bash

script_name=$(basename "${0}")
output_file="${script_name%.*}.json"

region="ap"
platform="pc"
puuid="86b05ddf-ed8b-50dd-994d-46769b29b66c"

curl -L \
    --url "https://api.henrikdev.xyz/valorant/v2/by-puuid/mmr-history/${region}/${platform}/${puuid}" \
    --header "Authorization: ${HENRIKDEV_ADVANCED_KEY}" \
    --header 'Accept: application/json' \
    -o "${output_file}"
