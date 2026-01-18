#!/usr/bin/env bash

# 1. Dynamic Filename Logic
script_name=$(basename "${0}")
output_file="${script_name%.*}.json"

# 2. Safety Check: Ensure 'jq' is installed
if ! command -v jq &>/dev/null; then
    echo "Error: 'jq' is not installed but is required for this script."
    exit 1
fi

# 3. Cleanup: Automatically remove temp files when script exits (even on error/Ctrl+C)
temp_page="page.tmp"
temp_merge="merge.tmp"
trap 'rm -f "${temp_page}" "${temp_merge}"' EXIT

account="ap/pc/itsme/NISHU"
api_url="https://api.henrikdev.xyz/valorant/v4/matches/${account}"
mode="competitive"
size=10
max_retries=3
retry_delay=2

start=0
page=1

# Initialize output file with an empty data structure
echo '{"status":200,"data":[]}' >"${output_file}"

while true; do
    echo "Fetching page ${page} (start=${start})..."

    attempt=1
    http_status=0
    response=""

    while [[ ${attempt} -le ${max_retries} ]]; do
        response=$(curl -s -L \
            -w "\n%{http_code}" \
            --url "${api_url}?mode=${mode}&size=${size}&start=${start}" \
            --header "Authorization: ${HENRIKDEV_ADVANCED_KEY}" \
            --header "Accept: application/json")

        http_status=$(echo "${response}" | tail -n1)
        body=$(echo "${response}" | sed '$d')

        if [[ "${http_status}" -eq 200 ]]; then
            break
        fi

        echo "Attempt ${attempt} failed (HTTP ${http_status}), retrying in ${retry_delay}s..."
        attempt=$((attempt + 1))
        sleep "${retry_delay}"
    done

    if [[ "${http_status}" -ne 200 ]]; then
        echo "Failed after ${max_retries} attempts. Exiting."
        exit 1
    fi

    # Check if we received any matches
    data_length=$(echo "${body}" | jq '.data | length')

    if [[ "${data_length}" -eq 0 ]]; then
        echo "No more match data found. Pagination complete."
        break
    fi

    # Write the current page body to a temp file
    echo "${body}" >"${temp_page}"

    # Merge the new data into the main file
    # Write to a temp merge file first to avoid corruption
    jq -s '.[0].data += .[1].data | .[0]' "${output_file}" "${temp_page}" >"${temp_merge}" &&
        mv "${temp_merge}" "${output_file}"

    page=$((page + 1))
    start=$((start + size))
done

echo "Success! All matches written to ${output_file}"
