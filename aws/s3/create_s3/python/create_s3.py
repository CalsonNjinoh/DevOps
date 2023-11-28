import boto3
from botocore.exceptions import ClientError

def create_bucket(bucket_name, region=None):
    """Create an S3 bucket in a specified region"""
    try:
        if region is None:
            s3_client = boto3.client('s3')
            s3_client.create_bucket(Bucket=bucket_name)
        else:
            s3_client = boto3.client('s3', region_name=region)
            location = {'LocationConstraint': region}
            s3_client.create_bucket(Bucket=bucket_name, CreateBucketConfiguration=location)
    except ClientError as e:
        print(f"Error: {e}")
        return False
    return True

def main():
  
    ##### List of bucket names to create ####
    #########################################

    bucket_name_list = ["john316", "pastormak234", "elonmusk12345"]

    # Specify the AWS region
    region = "ca-central-1"  # Change to your region

    for bucket_name in bucket_name_list:
        if create_bucket(bucket_name, region):
            print(f"Bucket {bucket_name} created.")

if __name__ == '__main__':
    main()

