Jenkins Upgrade Guide

Purpose

This guide provides detailed instructions for upgrading Jenkins on an Ubuntu server. The upgrade process involves backing up the existing Jenkins WAR file, stopping the Jenkins service, applying the upgrade, and then restarting the service. This guide is designed to ensure a smooth upgrade with minimal downtime.

Backup Jenkins WAR File

Before upgrading, it's important to backup the jenkins.war file. This file contains the core Jenkins application and is essential for restoration in case of any issues.

Locating the jenkins.war File:

Navigate to the Jenkins web interface.
Go to Manage Jenkins → System Information.
Find the executable-war property to see the path of the jenkins.war file.
Backup Command:

```bash
copy code
sudo cp /usr/share/java/jenkins.war /path/to/backup/location/
Upgrade Process

Stop Jenkins Service
First, stop the Jenkins service to prevent any conflicts during the upgrade.

Command to Stop Jenkins:

```bash
Copy code
sudo systemctl stop jenkins

Update Package List
Ensure your system's package list is up-to-date before upgrading Jenkins.

Command to Update Packages:

```bash
Copy code
sudo apt update
Upgrade Jenkins
Apply the Jenkins upgrade using the following command.

Command to Upgrade Jenkins:

```bash
Copy code
sudo apt-get upgrade jenkins
Restart Jenkins Service
After the upgrade, restart the Jenkins service to apply the changes.

Command to Start Jenkins:

```bash
Copy code
sudo systemctl start jenkins
Post-Upgrade Steps

Verify the Upgrade
Ensure that Jenkins has been successfully upgraded by checking the version number in the web interface.

Delete the Old WAR File (Optional)
If the upgrade was successful and there's no need to rollback, you can delete the old jenkins.war file.

Command to Remove Old WAR File:

```bash
Copy code
sudo rm /path/to/backup/location/jenkins.war
Rollback Procedure

In case of any issues with the new version:

Stop the Jenkins service.
Restore the jenkins.war file from your backup.
Restart the Jenkins service.
Replace /path/to/backup/location/ with your actual backup location. This README format follows best practices for clarity and ease of use, making it straightforward for users to follow the upgrade process.