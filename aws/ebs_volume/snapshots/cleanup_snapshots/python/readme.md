EBS Snapshot Cleanup Script

This script deletes AWS EBS snapshots that are older than 30 days. It is designed to handle large numbers of snapshots by paginating through the results.

Prerequisites

Python 3.x
Boto3 library installed (pip install boto3)
Setup

AWS Credentials: Ensure you have your AWS credentials set up. This can be done in multiple ways:
Using the AWS CLI: aws configure
Environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
IAM roles (if running on EC2 or AWS Lambda)
The ~/.aws/credentials file.
IAM Permissions: The AWS credentials being used should have permissions to list and delete snapshots. Here's a suggested policy:
json
Copy code
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeSnapshots",
        "ec2:DeleteSnapshot"
      ],
      "Resource": "*"
    }
  ]
}
Region: Replace YOUR_AWS_REGION in the script with your desired AWS region, e.g., 'us-west-1'.
Usage

Simply run the script:

bash
Copy code
python delete_old_snapshots.py
Important Notes

Testing: Before running this in a production environment, test it in a safe environment to ensure it doesn't inadvertently delete necessary data.
Backup: Always ensure you have proper backups and understand what data is stored in these snapshots before deleting them.
Cost: Deleting snapshots can save on storage costs, but ensure you aren't deleting snapshots that are still needed.
Automation: Consider running this script regularly (e.g., as a daily cron job) to maintain a clean snapshot environment.

