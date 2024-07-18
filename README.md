**Auto-Logout Script for Inactive Lab Machines**



**Overview**
This repository contains two Bash scripts designed to manage and enforce auto-logout on inactive macOS lab machines using Jamf. The scripts ensure that machines are automatically logged out after a specified idle time, helping to maintain security and efficiency in lab environments.

**Scripts Included**
auto_logout_setup.sh: This script sets up a launch daemon (com.denison.autologout.plist) that triggers a Jamf policy (autologout) after a defined interval. It also disables system sleep to prevent interference with the logout process.

auto_logout_check.sh: This script checks for user idle time and initiates the logout process if the machine has been idle for a specified duration. It handles force-quitting applications and logging out the user either directly or after displaying a warning prompt using Jamf's jamfHelper.

**Setup Instructions**
Prerequisites
Jamf Pro: Ensure Jamf Pro is configured and accessible.
Jamf Helper: The jamfHelper binary must be present on the machines. Adjust the path in auto_logout_check.sh (jamfHelperPath) if necessary.
Admin Privileges: Scripts require sudo privileges to execute certain commands.
**Steps**
Clone the Repository:

Setup auto_logout_setup.sh:

Edit the auto_logout_setup.sh script to customize paths or settings if needed.
Execute the script on each lab machine to install the launch daemon and configure settings.
bash
Copy code
sudo ./auto_logout_setup.sh
Deploy auto_logout_check.sh via Jamf:

Upload auto_logout_check.sh to your Jamf Pro console.
Create a policy in Jamf Pro to deploy auto_logout_check.sh and set it to run recurrently (e.g., every 5 minutes).
Ensure the policy runs with root privileges to manage applications and logout actions.
Testing and Troubleshooting:

Test the setup by leaving a machine idle for the specified duration to verify auto-logout functionality.
Review logs (/tmp/com.denison.autologout.out and /tmp/com.denison.autologout.err) for any issues.
**Notes**
Idle Time: Adjust the idle time threshold (900 seconds by default, equals 15 minutes) in auto_logout_check.sh as per your lab's requirements.
Customization: Modify the scripts according to specific needs, such as changing the warning message or adding additional checks.
Security: Ensure proper security measures are in place, as auto-logout involves force-quitting applications and potentially interrupting user sessions.
