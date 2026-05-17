#!/usr/bin/env bash

# ========================================================================
# Uninstall command
# adb shell pm uninstall --user 0 com.android.chrome
# ========================================================================
# If uninstall fails, disable command
# adb shell pm disable-user --user 0 com.miui.android.fashiongallery
# ========================================================================
# -k argument for keeping cache and userdata stuff
# ========================================================================
# Install command
# adb shell pm install-existing com.android.chrome
# ========================================================================
# (Get package name from app "Package Name Viewer 2.0"
# or App info in settings)
# Guides : https://youtu.be/OE_V1_Nyk8Q?si=0GwbVOGKGyzaXe5v
# https://youtu.be/6w6qD1QgzlA?si=YjDFbd5j1mVeIRyB
# ========================================================================
# DO NOT UNINSTALL
# com.miui.securitycenter
# com.miui.securityadd
# com.xiaomi.finddevice
# com.lbe.security.miui
# com.android.updater
# com.miui.home
# com.miui.guardprovider
# com.xiaomi.account
# com.miui.packageinstaller
# com.xiaomi.market
# ========================================================================

# Runtime argument
if [[ "$1" == "install" ]]; then
    script_cmd="adb shell pm install-existing --user 0"
else
    script_cmd="adb shell pm uninstall --user 0"
    disable_cmd="adb shell pm disable-user --user 0"
fi

# Function to print a divider line
print_divider() {
    echo -ne "${CYAN}"
    for ((i = 0; i < 72; i++)); do
        printf "="
    done
    echo -e "${RESET}"
}

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

# Function to pause before exiting if running in a separate window
pause_and_exit() {
    local exit_code="${1:-0}"
    if [ "$SHLVL" -eq 1 ]; then
        echo -e "${YELLOW}Press any key to exit...${RESET}"
        read -rsn1
    fi
    return "$exit_code" 2>/dev/null || exit "$exit_code"
}

# Function to handle install/uninstall/disable logic
process_packages() {
    {
        printf -v LOG_TIMESTAMP "%(%Y-%m-%d___%H:%M:%S)T" -1
        print_divider
        echo -e "${CYAN}Date: ${LOG_TIMESTAMP//___/\\nTime: }${RESET}"
        print_divider

        # Initialize counters for the summary
        local main_success_count=0
        local main_fail_count=0
        local disable_success_count=0
        local disable_fail_count=0
        local not_installed=0

        for pkg in "$@"; do
            current_cmd="$script_cmd $pkg"
            cmd_output=$($current_cmd 2>&1 | tr -d '\r')

            # Print the command in white and package name in blue
            echo -e "${WHITE}$script_cmd ${BLUE}$pkg${RESET}"

            # Evaluate the output to set colors and increment counters
            if [[ "$cmd_output" == *"Success"* ]] || [[ "$cmd_output" == *"installed for user"* ]]; then
                echo -e "${GREEN}$cmd_output${RESET}\n"
                ((main_success_count++))
            elif [[ "$cmd_output" == *"Failure [not installed for 0]"* ]] || [[ "$cmd_output" == *"doesn't exist"* ]]; then
                echo -e "${YELLOW}$cmd_output${RESET}\n"
                ((not_installed++))
            elif [[ "$script_cmd" == *"uninstall"* ]] && [[ "$cmd_output" == *"Failure [-1000]"* ]]; then
                # If it hits -1000, print initial failure in red
                echo -e "${RED}$cmd_output${RESET}\n"

                # Print the fallback note
                echo -e "${RED}Uninstall failed for $pkg, trying disabling...${RESET}\n"

                current_disable_cmd="$disable_cmd $pkg"
                # Print the fallback command in white and package name in blue
                echo -e "${WHITE}$disable_cmd ${BLUE}$pkg${RESET}"

                disable_output=$($current_disable_cmd 2>&1 | tr -d '\r')

                if [[ "$disable_output" == *"new state: disabled-user"* ]]; then
                    echo -e "${GREEN}$disable_output${RESET}\n"
                    ((disable_success_count++))
                else
                    echo -e "${RED}$disable_output${RESET}\n"
                    ((disable_fail_count++))
                fi
            else
                echo -e "${RED}$cmd_output${RESET}\n"
                ((main_fail_count++))
            fi
        done

        # Print the final execution summary
        print_divider
        echo -e "${MAGENTA}--- EXECUTION SUMMARY ---${RESET}"

        # Check if running uninstall or install
        if [[ "$script_cmd" == *"uninstall"* ]]; then
            [[ $main_success_count -gt 0 ]] && echo -e "${GREEN}Successfully Uninstalled : ${CYAN}$main_success_count${RESET}"
            [[ $main_fail_count -gt 0 ]] && echo -e "${RED}Failed to Uninstall      : ${CYAN}$main_fail_count${RESET}"
            [[ $disable_success_count -gt 0 ]] && echo -e "${GREEN}Successfully Disabled    : ${CYAN}$disable_success_count${RESET}"
            [[ $disable_fail_count -gt 0 ]] && echo -e "${RED}Failed to Disable        : ${CYAN}$disable_fail_count${RESET}"
        else
            [[ $main_success_count -gt 0 ]] && echo -e "${GREEN}Successfully Installed   : ${CYAN}$main_success_count${RESET}"
            [[ $main_fail_count -gt 0 ]] && echo -e "${RED}Failed to Install        : ${CYAN}$main_fail_count${RESET}"
        fi

        # Show not installed
        [[ $not_installed -gt 0 ]] && echo -e "${YELLOW}Not Found                : ${CYAN}$not_installed${RESET}"
    }
}

# Kill old server and start fresh
echo -e "${CYAN}Initializing ADB...${RESET}"
adb kill-server >/dev/null 2>&1
adb start-server >/dev/null 2>&1 || {
    echo -e "${RED}Error: Failed to start ADB server.${RESET}"
    pause_and_exit 1
}
print_divider

# Get list of connected, online devices
mapfile -t device_list < <(adb devices -l | awk 'NR>1 && $2=="device"')
device_count=${#device_list[@]}

if [ "$device_count" -eq 0 ]; then
    echo -e "${RED}Error: No device attached or device is unauthorized.${RESET}"
    echo -e "${RED}Please connect a device, allow USB debugging, and try again.${RESET}"
    print_divider
    pause_and_exit 1
fi

# Always prompt for device selection, even if only 1 is detected
echo -e "${YELLOW}Connected device(s) detected. Please select one to proceed:${RESET}"
for i in "${!device_list[@]}"; do
    serial=$(echo "${device_list[$i]}" | awk '{print $1}')
    model=$(echo "${device_list[$i]}" | grep -o 'model:[^ ]*' | cut -d: -f2)
    [[ -z "$model" ]] && model="Unknown" # Fallback if model name is missing
    echo -e "  ${CYAN}$((i + 1))${RESET}) ${WHITE}$serial${RESET} (Model: ${GREEN}$model${RESET})"
done
print_divider

while true; do
    read -p "Enter the number of your device (1-$device_count): " selection
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "$device_count" ]; then
        TARGET_SERIAL=$(echo "${device_list[$((selection - 1))]}" | awk '{print $1}')
        break
    else
        echo -e "${RED}Invalid input. Please enter a valid number between 1 and $device_count.${RESET}"
    fi
done

# Override command variables to target the specific device
if [[ "$1" == "install" ]]; then
    script_cmd="adb -s $TARGET_SERIAL shell pm install-existing --user 0"
else
    script_cmd="adb -s $TARGET_SERIAL shell pm uninstall --user 0"
    disable_cmd="adb -s $TARGET_SERIAL shell pm disable-user --user 0"
fi

# Array of packages
packages_to_remove=(
    "com.indus.appstore"
    "cn.wps.xiaomi.abroad.lite"
    "com.mi.android.globalminusscreen"
    "com.miui.cloudbackup"
    "com.android.chrome"
    "com.miui.cleaner"
    "com.facebook.services"
    "com.miui.bugreport"
    "com.mi.android.globalFileexplorer"
    "com.xiaomi.glgm"
    "com.xiaomi.mipicks"
    "com.google.android.gms.location.history"
    "com.miui.audiomonitor"
    "com.xiaomi.payment"
    "com.mint.keyboard"
    "com.mipay.wallet.in"
    "com.miui.player"
    "com.miui.notes"
    "com.miui.touchassistant"
    "com.miui.miservice"
    "com.xiaomi.midrop"
    "com.xiaomi.discover"
    "com.miui.weather2"
    "com.miui.yellowpage"
    "com.google.android.youtube"
    "com.google.android.apps.nbu.paisa.user"
    "com.google.android.apps.docs"
    "com.google.android.apps.maps"
    "in.amazon.mShop.android.shopping"
    "com.google.android.apps.tachyon"
    "com.facebook.katana"
    "com.google.android.videos"
    "com.google.ar.core"
    "com.mintgames.schuman.ablock"
    "com.linkedin.android"
    "com.mi.global.shop"
    "com.netflix.mediaclient"
    "com.amazon.avod.thirdpartyclient"
    "com.miui.android.fashiongallery"
    "com.mintgames.zentriple3d"
    "com.miui.analytics"
    "com.google.android.marvin.talkback"
    "com.google.android.setupwizard"
    "com.miui.backup"
    "com.facebook.system"
    "com.facebook.appmanager"
    "com.miui.freeform"
    "com.miui.micloudsync"
    "com.miui.cloudservice"
    "com.google.android.apps.photos"
    "com.miui.fm"
    "com.xiaomi.calendar"
    "com.google.android.apps.googleassistant.AssistantActivity"
    "com.google.android.apps.googleassistant"
    "com.google.android.apps.restore"
    "com.android.fileexplorer"
    "com.debug.loggerui"
    "com.google.android.apps.subscriptions.red.LauncherActivity"
    "com.google.android.apps.subscriptions.red"
    "com.google.ar.lens"
    "com.block.juggle"
    "com.google.android.apps.youtube.music"
)

# Run the function on the array
process_packages "${packages_to_remove[@]}"
print_divider

# Pause before exiting if launched directly from Windows Explorer
pause_and_exit 0
