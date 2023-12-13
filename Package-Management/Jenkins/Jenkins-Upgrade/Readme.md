markdown
Copy code
# Jenkins Upgrade Guide

## Overview
This document provides step-by-step instructions for upgrading Jenkins on an Ubuntu server. It includes backing up the current Jenkins installation to ensure minimal downtime.

## Prerequisites
- Administrative access to the Ubuntu server where Jenkins is installed.
- Access to the Jenkins web interface.

## Backup Jenkins WAR File
Before upgrading, back up the `jenkins.war` file, which contains the core Jenkins application.

### Locating the `jenkins.war` File
1. Navigate to the Jenkins web interface.
2. Go to **Manage Jenkins** → **System Information**.
3. Find the `executable-war` property to see the path of the `jenkins.war` file, typically at `/usr/share/java/jenkins.war`.

### Backup the WAR File
Run the following command to copy the `jenkins.war` file to a safe location:

```bash
sudo cp /usr/share/java/jenkins.war /path/to/backup/location/
Upgrade Process

Follow these steps to upgrade Jenkins:

Stop Jenkins Service
Stop the Jenkins service with this command:

bash
Copy code
sudo systemctl stop jenkins
Update Packages
Refresh the package list:

bash
Copy code
sudo apt-get update
Upgrade Jenkins
Upgrade Jenkins using this command:

bash
Copy code
sudo apt-get upgrade jenkins
Start Jenkins Service
After the upgrade, restart Jenkins:

bash
Copy code
sudo systemctl start jenkins
Post-Upgrade Steps

Verify Upgrade
Check the Jenkins version in the web interface to confirm the upgrade.

Delete Old WAR File (Optional)
If the upgrade is successful and you don't need to rollback, remove the old jenkins.war backup:

bash
Copy code
sudo rm /path/to/backup/location/jenkins.war
Rollback Plan

In case of issues:

Stop the Jenkins service.
Restore the jenkins.war file from the backup.
Start the Jenkins service.
vbnet
Copy code

Replace `/path/to/backup/location/` with the actual backup location. This Markdown formatting should display well on GitHub, making it easy for users to copy and paste the commands. Remember, it's always recommended to test these procedures in a non-production environment before applying them to live systems.