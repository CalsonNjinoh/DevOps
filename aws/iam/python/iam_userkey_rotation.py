import subprocess
import os
import configparser
from datetime import datetime

def run_command(command):
    try:
        return subprocess.check_output(command, stderr=subprocess.STDOUT, shell=True).decode('utf-8').strip()
    except subprocess.CalledProcessError as e:
        print(f"Command failed with error: {e.output.decode('utf-8')}")
        exit(1)

def main():
    # Check if AWS CLI is installed
    if not run_command("which aws"):
        print("AWS CLI is not installed.")
        exit(1)

    # Fetch the IAM username
    IAM_USERNAME = input("Please provide the IAM username: ")

    # Check if the user already has 2 access keys and delete the oldest if necessary
    EXISTING_KEYS = run_command(f"aws iam list-access-keys --user-name {IAM_USERNAME} --query 'AccessKeyMetadata[*].[AccessKeyId,CreateDate]' --output text")
    if EXISTING_KEYS.count("\n") >= 1:
        OLDEST_KEY = sorted([line.split("\t") for line in EXISTING_KEYS.split("\n")], key=lambda x: datetime.fromisoformat(x[1]))[0][0]
        print(f"User already has 2 access keys. Deleting the oldest one: {OLDEST_KEY}")
        run_command(f"aws iam delete-access-key --user-name {IAM_USERNAME} --access-key-id {OLDEST_KEY}")

    print(f"Creating a new access key for user: {IAM_USERNAME}...")
    NEW_KEY = run_command(f"aws iam create-access-key --user-name {IAM_USERNAME} --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text")
    NEW_ACCESS_KEY_ID, NEW_SECRET_ACCESS_KEY = NEW_KEY.split("\t")

    print("New access key created. Updating ~/.aws/credentials...")

    # Update ~/.aws/credentials with new key
    config = configparser.ConfigParser()
    config.read(os.path.expanduser("~/.aws/credentials"))
    if 'default' not in config:
        config['default'] = {}
    config['default']['aws_access_key_id'] = NEW_ACCESS_KEY_ID
    config['default']['aws_secret_access_key'] = NEW_SECRET_ACCESS_KEY
    with open(os.path.expanduser("~/.aws/credentials"), 'w') as configfile:
        config.write(configfile)

    print(f"Updated ~/.aws/credentials with new IAM keys for user {IAM_USERNAME}.")
    print("Old access key remains active. Ensure to test and verify manually.")

    # Check for environment variables
    if os.environ.get("AWS_ACCESS_KEY_ID") or os.environ.get("AWS_SECRET_ACCESS_KEY"):
        print("WARNING: You have AWS environment variables set (AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY). Please update or unset them to use the new keys.")

    print("Script completed.")

if __name__ == "__main__":
    main()
