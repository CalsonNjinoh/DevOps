#!/bin/bash

echo "Starting the script..."

# Ensure AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed."
    exit 1
fi

# Fetch the IAM username (if not provided as an argument)
if [ -z "$1" ]; then
    echo "Please provide the IAM username as an argument."
    exit 1
fi
IAM_USERNAME=$1

echo "Creating a new access key for user: $IAM_USERNAME..."
# Create a new access key
NEW_KEY=$(aws iam create-access-key --user-name "$IAM_USERNAME" --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text)

if [ $? -ne 0 ]; then
    echo "Failed to create new access key."
    exit 1
fi

NEW_ACCESS_KEY_ID=$(echo $NEW_KEY | awk '{print $1}')
NEW_SECRET_ACCESS_KEY=$(echo $NEW_KEY | awk '{print $2}')

echo "New access key created. Updating ~/.aws/credentials..."
# Update ~/.aws/credentials with new key
sed -i.bak "s/^aws_access_key_id = .*/aws_access_key_id = $NEW_ACCESS_KEY_ID/" ~/.aws/credentials
sed -i.bak "s/^aws_secret_access_key = .*/aws_secret_access_key = $NEW_SECRET_ACCESS_KEY/" ~/.aws/credentials

echo "Updated ~/.aws/credentials with new IAM keys for user $IAM_USERNAME."
echo "Old access key remains active. Ensure to test and verify manually."

# Clean up backup file created by sed
echo "Cleaning up backup files..."
rm ~/.aws/credentials.bak

echo "Script completed."

