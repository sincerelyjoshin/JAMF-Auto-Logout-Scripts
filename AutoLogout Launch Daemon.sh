#!/bin/bash

cat << EOF > /Library/LaunchDaemons/com.denison.autologout.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.denison.autologout</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/bin/jamf</string>
    <string>policy</string>
    <string>-event</string>
    <string>autologout</string>
  </array>
  <key>StartInterval</key>
  <integer>600</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/com.denison.autologout.out</string>
  <key>StandardErrorPath</key>
  <string>/tmp/com.denison.autologout.err</string>
</dict>
</plist>
EOF

sudo chmod 755 /Library/LaunchDaemons/com.denison.autologout.plist
sudo chown root:wheel /Library/LaunchDaemons/com.denison.autologout.plist
/bin/launchctl load /Library/LaunchDaemons/com.denison.autologout.plist
sudo pmset -a sleep 0