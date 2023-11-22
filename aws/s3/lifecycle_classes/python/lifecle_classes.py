import boto3

# Initialize the S3 client

s3_client = boto3.client('s3')

# Define bucket names

buckets = ["team4tech-access-logs"]  # Update with your bucket names

# Define which storage classes to use

storage_classes = {
    "STANDARD_IA": {"use": True, "days": 30},
    "INTELLIGENT_TIERING": {"use": True, "days": 60},
    "ONEZONE_IA": {"use": True, "days": 90},
    "GLACIER": {"use": True, "days": 180},
    "DEEP_ARCHIVE": {"use": True, "days": 270}
}

def create_lifecycle_policy():
    transitions = []
    current_day = 0

    for storage_class, settings in storage_classes.items():
        if settings["use"]:
            if settings["days"] <= current_day:
                raise ValueError(f"Days for {storage_class} must be greater than {current_day}")

            transitions.append({
                "Days": settings["days"],
                "StorageClass": storage_class
            })

            current_day = settings["days"]

    return {
        "Rules": [{
            "ID": "CustomLifecyclePolicy",
            "Prefix": "",
            "Status": "Enabled",
            "Transitions": transitions
        }]
    }

def apply_lifecycle_policy_to_bucket(bucket_name, lifecycle_policy):
    try:
        s3_client.put_bucket_lifecycle_configuration(
            Bucket=bucket_name,
            LifecycleConfiguration=lifecycle_policy
        )
        print(f"Lifecycle policy applied successfully to {bucket_name}")
    except Exception as e:
        print(f"Error applying lifecycle policy to {bucket_name}: {e}")

def main():
    lifecycle_policy = create_lifecycle_policy()

    for bucket in buckets:
        apply_lifecycle_policy_to_bucket(bucket, lifecycle_policy)

if __name__ == "__main__":
    main()
