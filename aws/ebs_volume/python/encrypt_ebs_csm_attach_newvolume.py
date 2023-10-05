import boto3
import time

# Configuration
EBS_VOLUME_IDS = ['vol-0997593764bc0cb42', 'vol-0514986f2509f01eb']
REGION = 'ca-central-1'
KMS_KEY_ID = '915d2b60-1ad7-48c9-9811-6ed5eaab0ea3'  # Replace with your KMS Key ID
WAIT_INTERVAL = 60
MAX_WAIT_TIME = 3600

ec2 = boto3.client('ec2', region_name=REGION)

def get_instance_name(instance_id):
    response = ec2.describe_instances(InstanceIds=[instance_id])
    for tag in response['Reservations'][0]['Instances'][0]['Tags']:
        if tag['Key'] == 'Name':
            return tag['Value']
    return None

def tag_volume_with_instance_name(volume_id, instance_id):
    instance_name = get_instance_name(instance_id)
    if instance_name:
        ec2.create_tags(Resources=[volume_id], Tags=[{'Key': 'Name', 'Value': f"{instance_name} - latest"}])

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

def detach_volume(volume_id):
    print(f"Detaching volume {volume_id}...")
    ec2.detach_volume(VolumeId=volume_id)
    while True:
        volume = ec2.describe_volumes(VolumeIds=[volume_id])
        if volume['Volumes'][0]['State'] == 'available':
            print(f"Volume {volume_id} is now detached!")
            return
        time.sleep(WAIT_INTERVAL)

def attach_volume(new_volume_id, instance_id, device):
    print(f"Attaching volume {new_volume_id} to EC2 instance {instance_id}...")
    ec2.attach_volume(VolumeId=new_volume_id, InstanceId=instance_id, Device=device)
    while True:
        volume = ec2.describe_volumes(VolumeIds=[new_volume_id])
        if volume['Volumes'][0]['State'] == 'in-use':
            print(f"Volume {new_volume_id} is now attached to {instance_id}!")
            return
        time.sleep(WAIT_INTERVAL)

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

def create_encrypted_volume_from_snapshot(snapshot_id, availability_zone):
    print(f"Creating encrypted volume from snapshot {snapshot_id} using KMS key {KMS_KEY_ID}...")
    response = ec2.create_volume(
        AvailabilityZone=availability_zone,
        SnapshotId=snapshot_id,
        Encrypted=True,
        KmsKeyId=KMS_KEY_ID  # Use the specified KMS key for encryption
    )
    volume_id = response['VolumeId']
    print(f"Encrypted volume created with ID: {volume_id}")

    print("Waiting for volume to become available...")
    if wait_for_volume(volume_id):
        print("Volume is now available!")
        return volume_id
    else:
        print("Max wait time exceeded for volume availability. Exiting.")
        exit(1)

def main():
    for volume_id in EBS_VOLUME_IDS:
        volume_details = ec2.describe_volumes(VolumeIds=[volume_id])
        availability_zone = volume_details['Volumes'][0]['AvailabilityZone']

        if volume_details['Volumes'][0]['State'] == 'in-use':
            instance_id = volume_details['Volumes'][0]['Attachments'][0]['InstanceId']
            device = volume_details['Volumes'][0]['Attachments'][0]['Device']

            snapshot_id = create_snapshot(volume_id)
            new_volume_id = create_encrypted_volume_from_snapshot(snapshot_id, availability_zone)
            
            # Tag the new volume with the EC2 instance name and 'latest'
            tag_volume_with_instance_name(new_volume_id, instance_id)

            detach_volume(volume_id)
            attach_volume(new_volume_id, instance_id, device)

            # Optional: Delete the original volume (uncomment if you're sure you want to delete it)
            # print(f"Deleting the original volume: {volume_id}")
            # ec2.delete_volume(VolumeId=volume_id)

if __name__ == "__main__":
    main()

