import boto3

# Initialize a session using Boto3
session = boto3.Session()
s3 = session.client('s3')

# List of your bucket names
buckets = ["team4techsolution-testbucket-2", "team4techsolutions-sandbox-vpc-flow-logs", "team4tech-demo-bucket"]  # Add your bucket names here

# Lifecycle policy
lifecycle_policy = {
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
}

# Function to apply the lifecycle policy to a bucket
def apply_lifecycle_policy(bucket_name):
    try:
        s3.put_bucket_lifecycle_configuration(
            Bucket=bucket_name,
            LifecycleConfiguration=lifecycle_policy
        )
        print(f"Lifecycle policy applied to bucket: {bucket_name}")
    except Exception as e:
        print(f"Error applying lifecycle policy to bucket {bucket_name}: {e}")

# Apply the policy to each bucket
for bucket in buckets:
    apply_lifecycle_policy(bucket)
