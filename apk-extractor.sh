#!/usr/bin/env bash

set -euo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

# Prevent Git for Windows (MSYS2) from converting /data/app/... into a local Windows path
export MSYS_NO_PATHCONV=1
SCRIPT_NAME="$(basename "$0")"
if [ "$#" -eq 0 ]; then
    trap 'echo -e "${YELLOW}Press enter to exit...${RESET}"; read -rsn1' EXIT
    echo -e "${MAGENTA}Usage: $SCRIPT_NAME <package_name>${RESET}"
    echo -e "${CYAN}e.g.: $SCRIPT_NAME com.android.chrome${RESET}"
    while [ -z "${PKG_NAME:-}" ]; do
        echo -ne "${YELLOW}Enter package name: ${RESET}"
        read -r PKG_NAME
    done
else
    PKG_NAME="$*"
fi

echo -e "${MAGENTA}Querying APK paths for: $PKG_NAME${RESET}"
mapfile -t APK_PATHS < <(adb shell pm path "$PKG_NAME" | sed 's/^package://; s/\r$//')

if [ "${#APK_PATHS[@]}" -eq 0 ] || [ -z "${APK_PATHS[0]}" ]; then
    echo -e "${RED}Error: No APK paths found for '$PKG_NAME'. Is the device connected and the app installed?${RESET}"
    exit 1
fi

mkdir -p "$PKG_NAME"
echo -e "${GREEN}Found ${#APK_PATHS[@]} file(s). Pulling into '$PKG_NAME/'...${RESET}"

for remote_apk in "${APK_PATHS[@]}"; do
    apk_name="$(basename "$remote_apk")"
    adb pull "$remote_apk" "$PKG_NAME/$apk_name"
done

echo -e "${GREEN}Done! All files saved to: $PKG_NAME/${RESET}"
