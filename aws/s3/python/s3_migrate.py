import boto3

def s3_bucket_migration(source_bucket, dest_bucket, profile_name):
    session = boto3.Session(profile_name=profile_name)
    s3 = session.resource('s3')

    # Iterate over source bucket objects and copy
    for obj_summary in s3.Bucket(source_bucket).objects.all():
        print(f"Copying {obj_summary.key}")
        dest_obj = s3.Object(dest_bucket, obj_summary.key)
        dest_obj.copy({'Bucket': source_bucket, 'Key': obj_summary.key})

if __name__ == '__main__':
    SOURCE_BUCKET = 'newteambucket'
    DESTINATION_BUCKET = 'team4tech-sandbox-bucket'
    PROFILE_NAME = 'sandbox'
    
    s3_bucket_migration(SOURCE_BUCKET, DESTINATION_BUCKET, PROFILE_NAME)

