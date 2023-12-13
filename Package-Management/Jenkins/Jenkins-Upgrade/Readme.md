markdown
Copy code
# Jenkins Upgrade Guide

## Purpose
This document provides the necessary steps to safely upgrade Jenkins on an Ubuntu server. The upgrade includes a backup of the current Jenkins WAR file, stopping the service, performing the upgrade, and restarting the service.

## Backup Jenkins WAR File
Create a backup of your `jenkins.war` file to ensure you can restore your setup if needed.

**Command to backup the `jenkins.war` file:**
```bash
```sudo cp /usr/share/java/jenkins.war /path/to/backup/location/jenkins.war.backup
Upgrade Process

Stop Jenkins Service
Ensure no jobs are running and stop the Jenkins service to prevent any conflicts during the upgrade.

Command to stop Jenkins:

bash
Copy code
sudo systemctl stop jenkins
Update Package List
Refresh your system's package list to ensure you have the latest updates before upgrading Jenkins.

Command to update packages:

bash
Copy code
sudo apt update
Upgrade Jenkins
Perform the upgrade using the following command. This will upgrade Jenkins to the latest version available in your package repository.

Command to upgrade Jenkins:

bash
Copy code
sudo apt-get install jenkins
Start Jenkins Service
Once the upgrade is complete, start the Jenkins service to apply the changes.

Command to start Jenkins:

bash
Copy code
sudo systemctl start jenkins
Post-Upgrade Steps

Verify the Upgrade
Check the Jenkins version in the web interface to confirm the upgrade was successful.

Delete the Old WAR File (Optional)
If you've verified the upgrade and are sure you won't need to rollback, you can remove the backup of the old jenkins.war file.

Command to remove the old WAR file:

bash
Copy code
sudo rm /path/to/backup/location/jenkins.war.backup
vbnet
Copy code

Remember to replace `/path/to/backup/location/` with the actual directory where you'd like to store your backup. Ensure you remove the triple backticks from the last line of the document in your README.md file on GitHub.
