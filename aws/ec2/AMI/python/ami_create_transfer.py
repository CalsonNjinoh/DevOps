import boto3
import time

# Configuration
INSTANCE_IDS = ["i-0dfba4e367311b7f6", "i-038c0de2acd999639", "i-0cee11319a62ac6d5"]
SOURCE_ACCOUNT = "370308050188"
DEST_ACCOUNT = "816037198234"
WAIT_INTERVAL = 60  # seconds
MAX_WAIT_TIME = 3600  # seconds (1 hour)

ec2 = boto3.client('ec2')

def get_instance_name(instance_id):
    """Fetch the name of the instance using its tags."""
    response = ec2.describe_instances(InstanceIds=[instance_id])
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            for tag in instance.get('Tags', []):
                if tag['Key'] == 'Name':
                    return tag['Value']
    return None

def create_ami(instance_id):
    """Create an AMI and return its ID."""
    instance_name = get_instance_name(instance_id)
    AMI_NAME = f"{instance_id}-AMI-{time.strftime('%Y-%m-%d')}"
    print(f"Creating AMI for instance {instance_id} with AMI name {AMI_NAME}...")
    response = ec2.create_image(InstanceId=instance_id, Name=AMI_NAME, NoReboot=True)
    print(f"AMI creation initiated. AMI ID: {response['ImageId']}")
    
    if instance_name:
        # Tagging the AMI with the EC2 instance's name
        ec2.create_tags(Resources=[response['ImageId']], Tags=[{'Key': 'Name', 'Value': instance_name}])
        print(f"AMI {response['ImageId']} tagged with EC2 instance name: {instance_name}")

    return response['ImageId']

def wait_for_ami(ami_id, instance_id):
    """Wait for the AMI to become available."""
    total_wait_time = 0
    while total_wait_time <= MAX_WAIT_TIME:
        ami = ec2.describe_images(ImageIds=[ami_id])
        ami_state = ami['Images'][0]['State']

        if ami_state == "available":
            print(f"AMI for {instance_id} is now available.")
            return True
        elif ami_state == "failed":
            print(f"AMI creation for {instance_id} failed.")
            return False
        else:
            print(f"AMI status for {instance_id}: {ami_state}. Waiting for another {WAIT_INTERVAL} seconds...")
            time.sleep(WAIT_INTERVAL)
            total_wait_time += WAIT_INTERVAL

    print(f"Reached maximum wait time of {MAX_WAIT_TIME/3600} hours for {instance_id}.")
    return False

def share_ami_and_snapshot(ami_id):
    """Share the given AMI and its snapshot with the DEST_ACCOUNT."""
    snapshot_id = ec2.describe_images(ImageIds=[ami_id])['Images'][0]['BlockDeviceMappings'][0]['Ebs']['SnapshotId']
    print(f"Sharing AMI with account {DEST_ACCOUNT}...")
    ec2.modify_image_attribute(ImageId=ami_id, LaunchPermission={'Add': [{'UserId': DEST_ACCOUNT}]})

    print(f"Sharing snapshot with account {DEST_ACCOUNT}...")
    ec2.modify_snapshot_attribute(SnapshotId=snapshot_id, Attribute='createVolumePermission',
                                  OperationType='add', UserIds=[DEST_ACCOUNT])

    print(f"AMI {ami_id} and snapshot {snapshot_id} shared successfully!")

def main():
    for instance_id in INSTANCE_IDS:
        ami_id = create_ami(instance_id)
        if wait_for_ami(ami_id, instance_id):
            share_ami_and_snapshot(ami_id)

if __name__ == "__main__":
    main()
