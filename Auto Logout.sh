#!/bin/bash

# Define variables
swiftDialogPath="/usr/local/bin/dialog"                                                                 # location of swiftDialog
jamfHelperPath="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"         # location of jamfHelper
windowTitle="Idle Logout Warning"                                                                       # window title text
windowMessage="You have been idle for a while. The computer is signing you out."                        # window message text
windowIcon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"        # window icon
windowTimeout=20                                                                                        # window timeout in seconds

# Exit if no users are logged in
if [ -z "$(who)" ]; then
    echo "No users logged in. Exiting script."
    exit 0
fi

force_quit_all_apps_and_logout() {
    for app in $(osascript -e 'tell application "System Events" to get name of every application process'); do
        osascript -e "quit app \"$app\""
    done
    echo "Force quit all applications complete."

    sudo pkill Dock
    sudo pkill loginwindow
    echo "Logged out successfully."
}

check_idle_time() {
    idle_time=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000)}')
    echo $idle_time
    if (( idle_time > 900 )); then # 900 seconds = 15 minutes
        echo "Logging out..."
        if is_screen_locked; then
            display_logout_warning
        else
            force_quit_all_apps_and_logout
        fi
    fi
}

is_screen_locked() {
    # Use ioreg to check if the screen is locked
    ioreg -n IODisplayWrangler | grep -q IOPowerManagement
    if [ $? -eq 0 ]; then
        return 1  # Screen is not locked (system is active)
    else
        return 0  # Screen is locked (system is in sleep or locked)
    fi
}

display_logout_warning() {
    # draw window using swiftDialog if installed, otherwise draw window with jamfHelper
    if [ -n "${swiftDialogPath}" ] && [ -e "${swiftDialogPath}" ]; then
        window=$( "$swiftDialogPath" --title "$windowTitle" --message "$windowMessage" --button1text "Confirm" --button2 --timer "$windowTimeout" --icon  "$windowIcon" --ontop --showonallscreens )
    else
        window=$( "$jamfHelperPath" -windowType utility -title "$windowTitle" -description "$windowMessage" -button1 "Confirm" -button2 "Cancel" -timeout "$windowTimeout" -countdown -icon "$windowIcon" -defaultButton 1 -cancelButton 2)
    fi

    result=$?

    if [[ "$result" == "0" ]]; then
        force_quit_all_apps_and_logout
    elif [[ "$result" == "2" ]];  then
        echo "User canceled logout."
        exit 0
    elif [[ "$result" == "4" ]]; then
        force_quit_all_apps_and_logout
    fi
}

# Check idle time
check_idle_time

echo "Script ran till EOF"
