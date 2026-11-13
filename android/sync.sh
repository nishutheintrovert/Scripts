#!/usr/bin/env bash

#	Author	: Nishikant Kanunje
#	Date	: 14/11/2026
#	Purpose	: Pulls and pushes paylod to /data/data directories using either ROOT or DEBUG ENABLED applications over adb (Supports Android versions 6+)

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
        die_with_pause "App data directory not found. Launch the app once to generate it."
else
    adb shell "run-as $PACKAGE_NAME [ -d . ]" >/dev/null 2>&1 ||
        die_with_pause "App data directory not found or app is not debuggable. Launch the app once to generate it."
fi

# ================= Functions ========================

# Snapshot pre-existing metadata via tar manifest, extract archive, and restore attributes on-device
extract_and_repair_root() {
    local TARGET_DIR="$1"
    local STAGE_TAR="$2"
    local PKG_NAME="$3"
    local PAYLOAD_SH="/data/local/tmp/${PKG_NAME}_repair.sh"

    cat <<'EOF' | tr -d '\r' | adb shell "cat > $PAYLOAD_SH && su -c 'sh $PAYLOAD_SH \"$TARGET_DIR\" \"$STAGE_TAR\" \"$PKG_NAME\"'; rm -f $PAYLOAD_SH"
TARGET_DIR="$1"
STAGE_TAR="$2"
PKG_NAME="$3"
SNAPSHOT_FILE="/data/local/tmp/${PKG_NAME}.meta"

cd "$TARGET_DIR" || exit 1

# 1. Resolve authoritative app UID/GID (also heals directories corrupted by prior pushes)
APP_UID=$(grep "^$PKG_NAME " /data/system/packages.list 2>/dev/null | cut -d' ' -f2)
[ -z "$APP_UID" ] && APP_UID=$(stat -c '%u' .)
APP_GID="$APP_UID"
APP_CTX=$(stat -c '%C' .)

# 2. Snapshot live metadata only for staged paths in the tarball before extracting
stat -c '%a %u %g %C %n' . > "$SNAPSHOT_FILE"
tar -tf "$STAGE_TAR" | while IFS= read -r entry; do
    [ -z "$entry" ] || [ "$entry" = "." ] || [ "$entry" = "./" ] && continue
    if [ -e "$entry" ] || [ -L "$entry" ]; then
        stat -c '%a %u %g %C %n' "$entry" >> "$SNAPSHOT_FILE"
    else
        printf 'NEW %s %s %s %s\n' "$APP_UID" "$APP_GID" "$APP_CTX" "$entry" >> "$SNAPSHOT_FILE"
    fi
done

# 3. Extract archive (host UID/GID is already normalized to 0:0 during packing)
tar -xf "$STAGE_TAR" || exit 1

# 4. Replay exact baseline metadata (or apply defaults to newly added files)
while read -r mode uid gid ctx path; do
    [ -z "$path" ] && continue
    # Heal UID/GID if target was previously corrupted to Windows UID (e.g., u1_i7609)
    if [ "$uid" != "$APP_UID" ]; then
        uid="$APP_UID"
        gid="$APP_GID"
    fi
    if [ "$mode" = "NEW" ]; then
        if [ -d "$path" ]; then
            mode="0771"
        else
            mode="0660"
        fi
    elif [ "$path" = "." ]; then
        mode="0700"
    else
        [ "${#mode}" -eq 3 ] && mode="0$mode"
    fi
    chown -h "$uid:$gid" "$path"
    [ ! -L "$path" ] && chmod "$mode" "$path"
    chcon -h "$ctx" "$path" 2>/dev/null
done < "$SNAPSHOT_FILE"

rm -f "$SNAPSHOT_FILE"
restorecon -RF "$TARGET_DIR" 2>/dev/null || true
EOF
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: On-device root extraction or metadata repair failed.${RESET}"
        exit 1
    fi
}

# Snapshot pre-existing permissions via tar manifest, extract archive, and restore modes via run-as
extract_and_repair_debug() {
    local STAGE_TAR="$1"
    local PKG_NAME="$2"

    cat <<'EOF' | tr -d '\r' | adb shell "run-as $PKG_NAME sh -s \"$STAGE_TAR\""
STAGE_TAR="$1"
SNAPSHOT_FILE="._sync_meta.tmp"

# 1. Snapshot live permissions only for staged paths in the tarball before extracting
stat -c '%a %n' . > "$SNAPSHOT_FILE"
tar -tf "$STAGE_TAR" | while IFS= read -r entry; do
    [ -z "$entry" ] || [ "$entry" = "." ] || [ "$entry" = "./" ] && continue
    if [ -e "$entry" ] || [ -L "$entry" ]; then
        stat -c '%a %n' "$entry" >> "$SNAPSHOT_FILE"
    else
        printf 'NEW %s\n' "$entry" >> "$SNAPSHOT_FILE"
    fi
done

# 2. Extract full archive cleanly using standard Toybox tar
tar -xf "$STAGE_TAR" || exit 1

# 3. Replay exact baseline permissions (or apply defaults to newly added files/dirs)
while read -r mode path; do
    [ -z "$path" ] && continue
    if [ "$mode" = "NEW" ]; then
        if [ -d "$path" ]; then
            mode="0771"
        else
            mode="0660"
        fi
    elif [ "$path" = "." ]; then
        mode="0700"
    else
        [ "${#mode}" -eq 3 ] && mode="0$mode"
    fi
    [ ! -L "$path" ] && chmod "$mode" "$path" 2>/dev/null
done < "$SNAPSHOT_FILE"

rm -f "$SNAPSHOT_FILE"
EOF
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: On-device debug extraction or permission repair failed.${RESET}"
        exit 1
    fi
}

# Runtime error helper and automatic staging cleanup trap
die() {
    echo -e "${RED}Error: $1${RESET}"
    exit 1
}

cleanup_staging() {
    rm -f "$LOCAL_TAR"
    if [ -n "$STAGE_TAR" ]; then
        adb shell "rm -f $STAGE_TAR" >/dev/null 2>&1
    fi
}

# Pull remote staging archive and extract into local package directory
pull_and_extract_local() {
    rm -f "$LOCAL_TAR"
    adb pull "/$STAGE_TAR" "$LOCAL_TAR" || die "Failed to pull archive from device."
    rm -rf "$PACKAGE_NAME" && mkdir -p "$PACKAGE_NAME"
    tar -xf "$LOCAL_TAR" -C "$PACKAGE_NAME" || die "Failed to extract archive locally."
    rm -f "$LOCAL_TAR"
}

# Pack local package directory and push to remote staging area
pack_and_push_staging() {
    rm -f "$LOCAL_TAR"
    tar --owner=0 --group=0 --numeric-owner $TAR_EXCLUDES -cf "$LOCAL_TAR" -C "$PACKAGE_NAME" . || die "Failed to create local tar archive."
    adb shell "rm -f $STAGE_TAR"
    adb push "$LOCAL_TAR" "/$STAGE_TAR" || die "Failed to push archive to device."
    rm -f "$LOCAL_TAR"
}

# Non-savegame directories to exclude from both pull and push archives
TAR_EXCLUDES="--exclude=./cache --exclude=./code_cache --exclude=./app_webview --exclude=./app_textures --exclude=./app_*cache* --exclude=./lib --exclude=./files/.Fabric --exclude=./files/.com.google.firebase.crashlytics*"

TARGET_DIR="/data/data/$PACKAGE_NAME"
LOCAL_TAR="${PACKAGE_NAME}.tar"
if [ "$MODE" = "root" ]; then
    STAGE_TAR="/data/local/tmp/${PACKAGE_NAME}_root.tar"
else
    STAGE_TAR="/data/local/tmp/${PACKAGE_NAME}.tar"
fi

# Register trap so local/remote .tar files are always cleaned up on exit or error
trap cleanup_staging EXIT

# Stop the app before processing core logic
adb shell "am force-stop $PACKAGE_NAME"

# Status banner
ACTION_LABEL="$([ "$ACTION" = "pull" ] && echo "Pulling" || echo "Pushing")"
echo -e "${GREEN}${ACTION_LABEL} package via ${MODE^^} mode...${RESET}"
echo "Package: $PACKAGE_NAME"

# Core logic execution
case "${MODE}_${ACTION}" in
    "root_pull")
        adb shell "rm -f $STAGE_TAR && su -c \"tar $TAR_EXCLUDES -C $TARGET_DIR -cf $STAGE_TAR . && chmod 644 $STAGE_TAR\"" ||
            die "Failed to create staging archive on device."
        pull_and_extract_local
        ;;

    "root_push")
        pack_and_push_staging
        echo "Extracting archive and restoring target metadata..."
        extract_and_repair_root "$TARGET_DIR" "$STAGE_TAR" "$PACKAGE_NAME"
        ;;

    "debug_pull")
        adb shell "rm -f $STAGE_TAR && run-as $PACKAGE_NAME tar $TAR_EXCLUDES -c . > $STAGE_TAR" ||
            die "Failed to create staging archive via run-as."
        pull_and_extract_local
        ;;

    "debug_push")
        pack_and_push_staging
        echo "Extracting archive and restoring target metadata..."
        extract_and_repair_debug "$STAGE_TAR" "$PACKAGE_NAME"
        ;;

    *)
        die "Should not have reached bro what the fuck!"
        ;;
esac

echo -e "${GREEN}Done!${RESET}"
