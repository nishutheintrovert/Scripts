#!/usr/bin/env bash

#	Author	: Nishikant Kanunje
#	Date	: 14/11/2026
#	Purpose	: Reinstalls app and loades it temporarily to generate directory structure in /data/data/ concurrently for adb devices

RED='\033[0;31m'
GREEN='\033[0;92m'
RESET='\033[0m'

PKG="com.wordsmobile.gunship"
APK_PATH="/d/makeDebuggable/com.wordsmobile.gunship/debug-enabled/*.apk"

# Get connected devices (handling Windows \r line endings safely)
DEVICES=$(adb devices | tr -d '\r' | awk '$2 == "device" {print $1}')

for serial in $DEVICES; do
    (
        echo -e "${RED}Uninstalling "$PKG" on [$serial]${RESET}"
        adb -s "$serial" uninstall "$PKG"
        echo -e "${RED}Installing "$PKG" on [$serial]${RESET}"
        adb -s "$serial" install-multiple $APK_PATH
        echo -e "${RED}Running "$PKG" on [$serial]${RESET}"
        adb -s "$serial" shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1
        echo -e "${RED}Waiting 10 seconds on [$serial]${RESET}"
        sleep 10
        echo -e "${RED}Killing "$PKG" on  [$serial]${RESET}"
        adb -s "$serial" shell am force-stop "$PKG"
        echo -e "${GREEN}[$serial] Done.${RESET}"
    ) &
done

# Wait for all device subshells to finish before exiting
wait
echo -e "${GREEN}Completed task on all devices!${RESET}"
