import boto3
import time

# Configuration
EBS_VOLUME_IDS = ['vol-0a5765714684fd704', 'vol-03a9a99ab8a623699']
REGION = 'ca-central-1'
KMS_KEY_ID = '915d2b60-1ad7-48c9-9811-6ed5eaab0ea3'  # Replace with your KMS Key ID

# Wait times
WAIT_INTERVAL = 60
MAX_WAIT_TIME = 3600

ec2 = boto3.client('ec2', region_name=REGION)

def get_ec2_name(instance_id):
    response = ec2.describe_tags(
        Filters=[
            {'Name': 'resource-id', 'Values': [instance_id]},
            {'Name': 'key', 'Values': ['Name']}
        ]
    )
    for tag in response.get('Tags', []):
        if tag['Key'] == 'Name':
            return tag['Value']
    return None

def get_volume_details(volume_id):
    response = ec2.describe_volumes(VolumeIds=[volume_id])
    volume = response['Volumes'][0]
    return volume['AvailabilityZone'], volume['Attachments'][0]['InstanceId']

def wait_for_snapshot(snapshot_id):
    total_wait_time = 0
    while total_wait_time <= MAX_WAIT_TIME:
        snapshot = ec2.describe_snapshots(SnapshotIds=[snapshot_id])
        if snapshot['Snapshots'][0]['State'] == 'completed':
            return True
        time.sleep(WAIT_INTERVAL)
        total_wait_time += WAIT_INTERVAL
    return False

def wait_for_volume(volume_id):
    total_wait_time = 0
    while total_wait_time <= MAX_WAIT_TIME:
        volume = ec2.describe_volumes(VolumeIds=[volume_id])
        if volume['Volumes'][0]['State'] == 'available':
            return True
        time.sleep(WAIT_INTERVAL)
        total_wait_time += WAIT_INTERVAL
    return False

def create_snapshot(volume_id):
    print(f"Creating snapshot from volume {volume_id}...")
    response = ec2.create_snapshot(VolumeId=volume_id, Description='Snapshot created by script')
    snapshot_id = response['SnapshotId']
    print(f"Snapshot created with ID: {snapshot_id}")

    print("Waiting for snapshot to complete...")
    if wait_for_snapshot(snapshot_id):
        print("Snapshot completed!")
        return snapshot_id
    else:
        print("Max wait time exceeded for snapshot completion. Exiting.")
        exit(1)

def create_encrypted_volume_from_snapshot(snapshot_id, availability_zone, instance_name):
    print(f"Creating encrypted volume from snapshot {snapshot_id} in {availability_zone}...")
    response = ec2.create_volume(
        AvailabilityZone=availability_zone,
        SnapshotId=snapshot_id,
        Encrypted=True,
        KmsKeyId=KMS_KEY_ID  # Use the custom KMS key here
    )
    volume_id = response['VolumeId']
    print(f"Encrypted volume created with ID: {volume_id}")

    if instance_name:
        ec2.create_tags(Resources=[volume_id], Tags=[{'Key': 'Name', 'Value': instance_name}])
        print(f"Tagged volume {volume_id} with EC2 instance name: {instance_name}")

    print("Waiting for volume to become available...")
    if wait_for_volume(volume_id):
        print("Volume is now available!")
        return volume_id
    else:
        print("Max wait time exceeded for volume availability. Exiting.")
        exit(1)

def main():
    for volume_id in EBS_VOLUME_IDS:
        availability_zone, instance_id = get_volume_details(volume_id)
        instance_name = get_ec2_name(instance_id)
        
        snapshot_id = create_snapshot(volume_id)
        create_encrypted_volume_from_snapshot(snapshot_id, availability_zone, instance_name)

if __name__ == "__main__":
    main()
