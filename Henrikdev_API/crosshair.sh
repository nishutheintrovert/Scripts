#!/usr/bin/env bash

script_name=$(basename "${0}")
output_file="${script_name%.*}.png"

crosshair_id="0;s;1;P;c;5;h;0;0t;7;0l;1;0v;1;0o;2;0a;1;0f;0;1b;0;S;d;0"

curl -L \
    --url "https://api.henrikdev.xyz/valorant/v1/crosshair/generate?id=${crosshair_id}" \
    --header "Authorization: ${HENRIKDEV_ADVANCED_KEY}" \
    --header 'Accept: image/png' \
    -o "${output_file}"
