## S3 Lifecycle Policy Management Scripts

This repository contains two scripts for managing AWS S3 bucket lifecycle policies: one written in Python and another in Bash. These scripts enable the application of lifecycle policies to specified S3 buckets, controlling how objects transition between storage classes over time.

## Features

Flexible Configuration: Easily enable or disable transitions to various storage classes like STANDARD_IA, INTELLIGENT_TIERING, ONEZONE_IA, GLACIER, and DEEP_ARCHIVE.
Multiple Bucket Support: Apply lifecycle policies to multiple buckets simultaneously.
Customizable Transition Periods: Set custom days for transition to each storage class.
Prerequisites

AWS CLI installed and configured with necessary permissions.
Python 3.x for running the Python script.
Bash shell for running the Bash script.
Setup

Clone the Repository:
bash
Copy code
git clone [repository-url]
cd [repository-directory]
Configure AWS CLI:
Ensure that AWS CLI is configured with appropriate credentials. Run aws configure to set up.
Using the Python Script

Script Location
lifecycle_policy.py

Usage
Modify the script variables to set the bucket names and policy preferences.
Run the script:
bash
Copy code
python3 lifecycle_policy.py
Customization
Edit the script to modify the bucket names, transition days, and enable/disable specific storage classes.

Using the Bash Script

Script Location
lifecycle_policy.sh

Usage
Modify the script variables to set the bucket names and policy preferences.
Run the script:
bash
Copy code
bash lifecycle_policy.sh
Customization
Adjust the variables at the top of the script to set the bucket names, transition days, and to enable/disable specific storage classes.

Troubleshooting

Ensure AWS CLI is properly configured with the correct region and credentials.
Check for proper installation of Python (for Python script) and Bash environment.
Review any error messages in the console for clues on issues.
