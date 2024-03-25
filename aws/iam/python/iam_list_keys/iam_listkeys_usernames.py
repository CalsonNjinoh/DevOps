import boto3

# Create an IAM service client
iam = boto3.client('iam')

# List all IAM users
response = iam.list_users()
users = response['Users']

for user in users:
    username = user['UserName']
    print(f"User: {username}")
    print("Access Keys:")
    
    # List access keys for the user
    keys_response = iam.list_access_keys(UserName=username)
    for key in keys_response['AccessKeyMetadata']:
        print(key['AccessKeyId'])
    print("-----")
