#!/bin/bash

# Define bucket names
buckets=("team4tech-access-logs" "newteambucket") # Update with your actual bucket names

# Storage class settings (true to enable, false to disable)
USE_STANDARD_IA=true
USE_INTELLIGENT_TIERING=true
USE_ONEZONE_IA=true
USE_GLACIER=true
USE_DEEP_ARCHIVE=true

# Days for transition
DAYS_TO_STANDARD_IA=30
DAYS_TO_INTELLIGENT_TIERING=60
DAYS_TO_ONEZONE_IA=90
DAYS_TO_GLACIER=180
DAYS_TO_DEEP_ARCHIVE=270

create_lifecycle_policy() {
    # Start lifecycle policy JSON array
    transitions=()

    # Append transitions based on settings
    [[ "$USE_STANDARD_IA" == true ]] && transitions+=("{\"Days\": $DAYS_TO_STANDARD_IA, \"StorageClass\": \"STANDARD_IA\"}")
    [[ "$USE_INTELLIGENT_TIERING" == true ]] && transitions+=("{\"Days\": $DAYS_TO_INTELLIGENT_TIERING, \"StorageClass\": \"INTELLIGENT_TIERING\"}")
    [[ "$USE_ONEZONE_IA" == true ]] && transitions+=("{\"Days\": $DAYS_TO_ONEZONE_IA, \"StorageClass\": \"ONEZONE_IA\"}")
    [[ "$USE_GLACIER" == true ]] && transitions+=("{\"Days\": $DAYS_TO_GLACIER, \"StorageClass\": \"GLACIER\"}")
    [[ "$USE_DEEP_ARCHIVE" == true ]] && transitions+=("{\"Days\": $DAYS_TO_DEEP_ARCHIVE, \"StorageClass\": \"DEEP_ARCHIVE\"}")

    # Join transitions with commas
    transitions_string=$(IFS=,; echo "${transitions[*]}")

    # Construct full lifecycle policy
    lifecycle_policy="{\"Rules\": [{\"ID\": \"CustomLifecyclePolicy\", \"Prefix\": \"\", \"Status\": \"Enabled\", \"Transitions\": [$transitions_string]}]}"

    echo "$lifecycle_policy"
}

apply_lifecycle_policy_to_bucket() {
    bucket_name=$1
    policy=$2

    # Write the policy to a temporary file
    policy_file=$(mktemp)
    echo "$policy" > "$policy_file"

    # Apply lifecycle policy
    echo "Applying lifecycle policy to $bucket_name"
    aws s3api put-bucket-lifecycle-configuration --bucket "$bucket_name" --lifecycle-configuration file://"$policy_file"
    if [[ $? -eq 0 ]]; then
        echo "Lifecycle policy applied successfully to $bucket_name"
    else
        echo "Error applying lifecycle policy to $bucket_name"
    fi

    # Remove the temporary file
    rm "$policy_file"
}

main() {
    lifecycle_policy=$(create_lifecycle_policy)

    for bucket in "${buckets[@]}"; do
        apply_lifecycle_policy_to_bucket "$bucket" "$lifecycle_policy"
    done
}

main
