# EC2 AMI Creation & Sharing Script

This script automates the process of creating Amazon Machine Images (AMIs) from specified EC2 instances and then shares those AMIs with another AWS account. Additionally, each created AMI will be tagged with the name of the original EC2 instance.

# Overview of Functionality

# AMI Creation: 
For each specified EC2 instance ID, the script creates an AMI.

# AMI Tagging: 
The created AMI will have a tag Name set to the name of the originating EC2 instance.

# AMI & Snapshot Sharing: 
The created AMI and its associated snapshot will be shared with a specified destination AWS account.

# Prerequisites

- # AWS CLI: 
Ensure you have the AWS Command Line Interface installed and configured with appropriate credentials.

- # Python and Boto3: 
The script is written in Python and uses the Boto3 library to interact with AWS services. Ensure you have Python and Boto3 installed.

- # AWS Permissions: 
The AWS credentials used must have permissions to describe EC2 instances, create AMIs, tag resources, and modify image and snapshot attributes.

# Configuration

Before using the script, a few configurations need to be set:

# INSTANCE_IDS: 

A list of EC2 instance IDs you want to create AMIs for

# SOURCE_ACCOUNT:

The AWS account ID where the script is running.

# DEST_ACCOUNT: 
The AWS account ID you want to share the created AMIs with.

# Usage

Adjust the configuration in the script.

Run the script:
python3 ami_create_transfer.py 

# Notes

- The script will tag the created AMI with the name of the EC2 instance to maintain clarity and traceability.

- Ensure you monitor your AWS resources and costs. Creating and storing AMIs will incur charges.

Troubleshooting

- InvalidAMIName.Malformed Error: Ensure that your EC2 instance names do not contain characters disallowed in AMI names. The script attempts to handle this, but special edge cases might occur.

- Permissions Error: Ensure your AWS credentials have the appropriate permissions. Check the AWS IAM console to adjust permissions.