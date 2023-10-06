# AWS IAM Key Rotation Script

This script assists in automating the process of rotating AWS IAM user access keys. It's particularly useful in environments where access keys need to be rotated regularly for security reasons.

## Features

- Automatically checks and deletes the oldest access key if the IAM user already has two active keys.
- Creates a new access key for the specified IAM user.
- Updates the local AWS CLI configuration with the new key.
- Enhanced logging for easier debugging and audit.

## Prerequisites

- AWS CLI installed and configured with the necessary permissions.
- An IAM user with permissions to manage access keys.
- A Unix-like operating system (Linux, macOS) with bash shell available.

## Usage

Clone this repository:
```bash
git clone https://github.com/CalsonNjinoh/DevOps.git
cd BASH_AUTOMATION_SCRIPTS

Grant execute permissions to the script:
chmod +x rotate_key.sh

Run the script with the desired IAM username:
rotate_key.sh YOUR_IAM_USERNAME

Replace YOUR_IAM_USERNAME with the name of the IAM user whose key you wish to rotate

Replace YOUR_IAM_USERNAME with the name of the IAM user whose key you wish to rotate.

## Recommendations

Always backup your AWS CLI configuration before running the script:

bash
Copy code
cp ~/.aws/credentials ~/.aws/credentials.backup

After running the script, manually verify both the old and new access keys to ensure everything works as expected.

Run this script every 60 days to update your IAM user details 