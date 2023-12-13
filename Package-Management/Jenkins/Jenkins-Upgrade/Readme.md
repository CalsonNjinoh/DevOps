Jenkins Upgrade Guide

Overview

This document provides step-by-step instructions to upgrade Jenkins on an Ubuntu server. Before proceeding with the upgrade, it is crucial to backup the current Jenkins installation and ensure minimal downtime.

Prerequisites

Administrative access to the Ubuntu server running Jenkins.
Access to the Jenkins web interface.
Backup Jenkins WAR File

The jenkins.war file contains the core Jenkins application. It is essential to backup this file before upgrading.

Locating the jenkins.war File
Find jenkins.war Path in Jenkins UI:
Navigate to your Jenkins web interface.
Go to Manage Jenkins → System Information.
Look for the executable-war property. This property shows the path of the jenkins.war file, typically /usr/share/java/jenkins.war.
Backup the WAR File
Backup jenkins.war via Terminal:
Connect to your server via SSH.
Run the following command to copy the jenkins.war file to a backup location:
bash
Copy code
sudo cp /usr/share/java/jenkins.war /path/to/backup/location/
Upgrade Process

Follow these steps to upgrade Jenkins.

Stop Jenkins Service
Stop Jenkins:
Execute the following command to stop the Jenkins service:
bash
Copy code
sudo systemctl stop jenkins
Update Packages
Update Package Lists:
Refresh the local package index:
bash
Copy code
sudo apt-get update
Upgrade Jenkins
Upgrade Jenkins:
Run the following command to upgrade Jenkins:
bash
Copy code
sudo apt-get upgrade jenkins
Start Jenkins Service
Start Jenkins:
Once the upgrade is complete, start the Jenkins service:
bash
Copy code
sudo systemctl start jenkins
Post-Upgrade Steps

Verify Upgrade
Check Jenkins Version:
After restarting, verify the upgrade by logging into the Jenkins UI and checking the version number.
Delete Old WAR File
Remove Old WAR File (Optional):
If the upgrade was successful and you're sure you won't need to rollback, you can delete the old jenkins.war backup:
bash
Copy code
sudo rm /path/to/backup/location/jenkins.war
Rollback Plan

In case of any issues post-upgrade:

Stop Jenkins service.
Restore the original jenkins.war file from your backup.
Start Jenkins service.
Remember to replace /path/to/backup/location/ with the actual path where you want to store your backups. Also, ensure that you have tested this process in a staging environment before applying it to a production server.
