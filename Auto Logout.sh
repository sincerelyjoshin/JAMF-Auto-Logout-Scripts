#!/bin/bash

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
    jamfHelperPath="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
    message="You have been idle for a while. The computer is signing you out."
    timeout=20
    icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"

    button=$( "$jamfHelperPath" -windowType utility -title "Idle Logout Warning" -description "$message" -button1 "Cancel" -button2 "Logout" -timeout "$timeout" -countdown -icon "$icon" -defaultButton 2 -cancelButton 1)
echo "$button"

    if [[ "$button" == "0" ]]; then
        echo "User canceled logout."
        exit 0
	elif [[ "$button" == "2" ]];  then
        force_quit_all_apps_and_logout
    fi
}

# Check idle time
check_idle_time

echo "Script ran till EOF"