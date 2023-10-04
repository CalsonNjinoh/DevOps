import boto3

# Configuration
AWS_REGION = 'ca-central-1'
DEV_VPC_ID = 'vpc-08a9101455ec0fabd'
JENKINS_EC2_ID = 'i-06e0738c34f5cc9e6'

# Initialize a session using Amazon EC2
ec2 = boto3.client('ec2', region_name=AWS_REGION)

def get_instance_ids(vpc_id):
    """Fetch instances associated with the given VPC."""
    response = ec2.describe_instances(
        Filters=[
            {
                'Name': 'vpc-id',
                'Values': [vpc_id]
            }
        ]
    )

    instance_ids = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_ids.append(instance['InstanceId'])
    return instance_ids

def start_instances(instance_ids):
    """Start the given EC2 instances."""
    for instance_id in instance_ids:
        if instance_id != JENKINS_EC2_ID:
            print(f"Starting the Dev Instance: {instance_id}")
            ec2.start_instances(InstanceIds=[instance_id])
        else:
            print(f"Skipping Jenkins server: {instance_id}")

if __name__ == "__main__":
    instance_ids = get_instance_ids(DEV_VPC_ID)
    start_instances(instance_ids)

