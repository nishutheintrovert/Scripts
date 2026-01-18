#!/usr/bin/env bash

script_name=$(basename "${0}")
output_file="${script_name%.*}.json"

region="ap"
match_id="d558d979-8155-4c77-9819-f81bab28e305"

curl -L \
    --url "https://api.henrikdev.xyz/valorant/v4/match/${region}/${match_id}" \
    --header "Authorization: ${HENRIKDEV_ADVANCED_KEY}" \
    --header 'Accept: application/json' \
    -o "${output_file}"
