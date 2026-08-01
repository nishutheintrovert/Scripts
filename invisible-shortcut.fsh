#!/usr/bin/env bash

#	Author	: Nishikant Kanunje
#	Date	: 03/06/2026
#	Purpose	: Create invisible shortcut at desktop

# Make sure direcotory exists
ICON_DIR="D:/Pictures/Icons"
[[ ! -d "$ICON_DIR" ]] && echo "Creating direcotry..." && /usr/bin/mkdir -p "$ICON_DIR"

# Create icon if doesn't exists
ICON_FILE="transparent.ico"

if [ ! -f "$ICON_DIR/$ICON_FILE" ]; then
    echo -e "Creating icon..."
    # magick -size 256x256 xc:transparent -colorspace sRGB -type truecolormatte -define icon:auto-resize=256,128,64,48,32,16 "$ICON_DIR/$ICON_FILE"
    # magick shit doesn't work, its a fucking rabbithole
    # this one actually worked like a fucking magick
    /usr/bin/bash "./goated-transparent-icon.fsh" "$ICON_DIR/$ICON_FILE"
fi

# Unique naming for shortcuts
TARGET_DIR="$USERPROFILE/Desktop"
NBSP=$'\xC2\xA0'
SHORTCUT_NAME="$NBSP"

while [ -f "$TARGET_DIR/$SHORTCUT_NAME.lnk" ]; do
    SHORTCUT_NAME="$SHORTCUT_NAME$NBSP"
done

SHORTCUT_FILE="$TARGET_DIR/$SHORTCUT_NAME.lnk"

# Execute powershell to create shortcut
TARGET_PATH="C:\Windows\System32\rundll32.exe"
TARGET_ARGS=""
ICON_LOCATION="$ICON_DIR/$ICON_FILE"

/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "
    \$wsh = New-Object -ComObject WScript.Shell;
    \$lnk = \$wsh.CreateShortcut('$SHORTCUT_FILE');
    \$lnk.TargetPath = '$TARGET_PATH';
    \$lnk.Arguments = '\"$TARGET_ARGS\"';
    \$lnk.IconLocation = '$ICON_LOCATION';
    \$lnk.Save();
"
