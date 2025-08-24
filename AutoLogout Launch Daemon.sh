#!/bin/bash

# Define variables
daemonLabel="com.denison.autologout"                  # Unique launchd identifier
jamfEvent="autologout"                                # Jamf Pro policy event
runInterval="600"                                     # Frequency, in seconds

cat << EOF > /Library/LaunchDaemons/"${daemonLabel}".plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$daemonLabel</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/bin/jamf</string>
    <string>policy</string>
    <string>-event</string>
    <string>$jamfEvent</string>
  </array>
  <key>StartInterval</key>
  <integer>$runInterval</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/$daemonLabel.out</string>
  <key>StandardErrorPath</key>
  <string>/tmp/$daemonLabel.err</string>
</dict>
</plist>
EOF

chmod 755 /Library/LaunchDaemons/"${daemonLabel}".plist
chown root:wheel /Library/LaunchDaemons/"${daemonLabel}".plist
launchctl load /Library/LaunchDaemons/"${daemonLabel}".plist
pmset -a sleep 0

exit 0
