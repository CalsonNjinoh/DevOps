#!/bin/bash

# Define AWS profiles
SOURCE_PROFILE="source-profile"
TARGET_PROFILE="target-profile"

# List all secrets from the source account
SECRETS=$(aws secretsmanager list-secrets --profile $SOURCE_PROFILE | jq -r '.SecretList[].Name')

# Check if we got any secrets
if [ -z "$SECRETS" ]; then
  echo "No secrets found in source profile: $SOURCE_PROFILE"
  exit 1
fi

# Loop through each secret and copy its value to the target account
for SECRET in $SECRETS; do
  echo "Migrating secret: $SECRET"

  # Get the secret value
  SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id $SECRET --profile $SOURCE_PROFILE | jq -r '.SecretString')

  # Re-create this secret in the target account
  aws secretsmanager create-secret --name $SECRET --secret-string "$SECRET_VALUE" --profile $TARGET_PROFILE

  if [ $? -ne 0 ]; then
      echo "Error occurred while migrating $SECRET. Continuing with next..."
  fi
done

echo "Migration completed."