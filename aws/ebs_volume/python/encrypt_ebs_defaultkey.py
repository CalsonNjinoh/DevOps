import boto3
import time

# Configuration
EBS_VOLUME_IDS = ["VOLUME_ID_1", "VOLUME_ID_2"]  # Replace with your list of EBS volume IDs
REGION = "us-west-1"  # Replace with your AWS region
AVAILABILITY_ZONE = "us-west-1a"  # Replace with the availability zone where you want the new volumes to reside

# Wait times
WAIT_INTERVAL = 60  # Check every 60 seconds
MAX_WAIT_TIME = 3600  # Maximum wait time of 1 hour for both snapshot and volume

ec2 = boto3.client('ec2', region_name=REGION)


def create_snapshot(volume_id):
    print(f"Creating snapshot from volume {volume_id}...")
    response = ec2.create_snapshot(VolumeId=volume_id, Description='Snapshot created by script')
    snapshot_id = response['SnapshotId']
    print(f"Snapshot created with ID: {snapshot_id}")

    elapsed_time = 0
    while elapsed_time <= MAX_WAIT_TIME:
        response = ec2.describe_snapshots(SnapshotIds=[snapshot_id])
        status = response['Snapshots'][0]['State']
        if status == "completed":
            print("Snapshot completed!")
            return snapshot_id
        time.sleep(WAIT_INTERVAL)
        elapsed_time += WAIT_INTERVAL

    print("Max wait time exceeded for snapshot completion. Exiting.")
    exit(1)


def create_encrypted_volume_from_snapshot(snapshot_id):
    print(f"Creating encrypted volume from snapshot {snapshot_id} using default AWS key...")
    response = ec2.create_volume(AvailabilityZone=AVAILABILITY_ZONE, SnapshotId=snapshot_id, Encrypted=True)
    volume_id = response['VolumeId']
    print(f"Encrypted volume created with ID: {volume_id}")

    elapsed_time = 0
    while elapsed_time <= MAX_WAIT_TIME:
        response = ec2.describe_volumes(VolumeIds=[volume_id])
        status = response['Volumes'][0]['State']
        if status == "available":
            print("Volume is now available!")
            return volume_id
        time.sleep(WAIT_INTERVAL)
        elapsed_time += WAIT_INTERVAL

    print("Max wait time exceeded for volume availability. Exiting.")
    exit(1)


# Main Execution
if __name__ == "__main__":
    for volume_id in EBS_VOLUME_IDS:
        snapshot_id = create_snapshot(volume_id)
        create_encrypted_volume_from_snapshot(snapshot_id)
