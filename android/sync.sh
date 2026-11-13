#!/usr/bin/env bash

#	Author	: Nishikant Kanunje
#	Date	: 14/11/2026
#	Purpose	: Pulls and pushes paylod to /data/data directories using either ROOT or DEBUG ENABLED applications over adb (Supports Android versions 10+.. (Dropped support for Android versions below 10 to reduce string parsing and permission and subshell hell)

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

# Helper for validation errors (prints message, optionally prints usage, and pauses before exiting)
die_with_pause() {
    local msg="$1"
    local show_usage="${2:-0}"
    trap 'echo -e "${YELLOW}Press enter to exit...${RESET}"; read -rsn1' EXIT
    [ -n "$msg" ] && echo -e "${RED}Error: ${msg}${RESET}"
    if [ "$show_usage" -eq 1 ]; then
        echo -e "${CYAN}Usage: $SCRIPT_NAME [root|debug] [pull|push] [package_name]${RESET}"
    fi
    exit 1
}

# Validate argument count
if [ "$#" -ne 3 ]; then
    trap 'echo -e "${YELLOW}Press enter to exit...${RESET}"; read -rsn1' EXIT
    echo -e "${MAGENTA}Usage: $SCRIPT_NAME [root|debug] [pull|push] [package_name]${RESET}"
    echo -e "${CYAN}e.g.:  $SCRIPT_NAME root pull com.android.chrome${RESET}"
    exit 1
fi

# Assign arguments to variables
MODE="$1"
ACTION="$2"
PACKAGE_NAME="$3"

# Validate action and mode
[[ "$ACTION" != "pull" && "$ACTION" != "push" ]] && die_with_pause "Invalid action '${ACTION}'. Must be 'pull' or 'push'." 1
[[ "$MODE" != "root" && "$MODE" != "debug" ]] && die_with_pause "Invalid mode '${MODE}'. Must be 'root' or 'debug'." 1

# Local directory check for PUSH modes
if [ "$ACTION" = "push" ] && [[ ! -d "$PACKAGE_NAME" ]]; then
    die_with_pause "$PACKAGE_NAME directory not found."
fi

# Verify app target directory exists on device before proceeding
if [ "$MODE" = "root" ]; then
    adb shell "su -c '[ -d \"/data/data/$PACKAGE_NAME\" ]'" >/dev/null 2>&1 ||
        die_with_pause "Cannot access directory, make sure device is rooted and directory exists."
else
    adb shell "run-as $PACKAGE_NAME [ -d . ]" >/dev/null 2>&1 ||
        die_with_pause "Cannot access directory, make sure app is debuggable and directory exists."
fi

# ================= Functions ========================

# Ensure command and pipeline failures exit immediately
set -eo pipefail

# Runtime error helper
die() {
    echo -e "${RED}Error: $1${RESET}"
    exit 1
}

# Non-savegame directories to exclude from both pull and push archives
TAR_EXCLUDES="--exclude=./cache --exclude=./code_cache --exclude=./app_webview --exclude=./app_textures --exclude=./app_*cache* --exclude=./lib --exclude=./files/.Fabric --exclude=./files/.com.google.firebase.crashlytics*"

TARGET_DIR="/data/data/$PACKAGE_NAME"

# Stop the app before processing core logic
adb shell "am force-stop $PACKAGE_NAME"

# Status banner
ACTION_LABEL="$([ "$ACTION" = "pull" ] && echo "Pulling" || echo "Pushing")"
echo -e "${GREEN}${ACTION_LABEL} package via ${MODE^^} mode...${RESET}"
echo "Package: $PACKAGE_NAME"

# Core logic execution
case "${MODE}_${ACTION}" in
    "root_pull")
        rm -rf "$PACKAGE_NAME"
        mkdir -p "$PACKAGE_NAME"
        adb exec-out "su -c 'tar $TAR_EXCLUDES -C $TARGET_DIR -cf - .'" | tar -xf - -C "$PACKAGE_NAME"
        ;;

    "root_push")
        echo "Pushing archive and restoring target metadata..."
        APP_UID=$(adb shell "su -c 'stat -c %u $TARGET_DIR'" | tr -d '\r')
        tar --owner="$APP_UID" --group="$APP_UID" --numeric-owner --mode='a-x,u=rwX,g=rwX,o=X' $TAR_EXCLUDES -cf sync.tar -C "$PACKAGE_NAME" .
        adb push sync.tar /data/local/tmp/sync.tar
        rm -f sync.tar
        adb shell "su -c 'tar -C $TARGET_DIR -xpf /data/local/tmp/sync.tar'"
        adb shell "su -c 'chmod 0700 $TARGET_DIR'"
        adb shell "su -c 'restorecon -RFD $TARGET_DIR'"
        adb shell "rm -f /data/local/tmp/sync.tar"
        ;;

    "debug_pull")
        rm -rf "$PACKAGE_NAME"
        mkdir -p "$PACKAGE_NAME"
        adb exec-out "run-as $PACKAGE_NAME tar $TAR_EXCLUDES -cf - ." | tar -xf - -C "$PACKAGE_NAME"
        ;;

    "debug_push")
        echo "Pushing archive and restoring target metadata..."
        tar --owner=0 --group=0 --numeric-owner --mode='a-x,u=rwX,g=rwX,o=X' $TAR_EXCLUDES -cf sync.tar -C "$PACKAGE_NAME" .
        adb push sync.tar /data/local/tmp/sync.tar
        rm -f sync.tar
        adb shell "run-as $PACKAGE_NAME sh -c 'tar -xpof /data/local/tmp/sync.tar && chmod 0700 .'"
        adb shell "rm -f /data/local/tmp/sync.tar"
        ;;

    *)
        die "Should not have reached bro what the fuck!"
        ;;
esac

echo -e "${GREEN}Done!${RESET}"
