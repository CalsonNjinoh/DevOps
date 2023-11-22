#!/bin/bash

# Define your bucket names
buckets=("learnbucket22" "newbucket-team4tech")  # Replace with your bucket names

# Define the lifecycle policy
lifecycle_policy='{
  "Rules": [
    {
      "ID": "MoveToStandardIAAndDelete",
      "Filter": {
        "Prefix": ""
      },
      "Status": "Enabled",
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        }
      ],
      "Expiration": {
        "Days": 60
      }
    }
  ]
}'

# Apply the lifecycle policy to each bucket
for bucket in "${buckets[@]}"
do
    echo "Applying lifecycle policy to $bucket"
    aws s3api put-bucket-lifecycle-configuration --bucket "$bucket" --lifecycle-configuration "$lifecycle_policy"
    if [ $? -eq 0 ]; then
        echo "Lifecycle policy applied successfully to $bucket"
    else
        echo "Error applying lifecycle policy to $bucket"
    fi
done

echo "Script execution completed."

