import boto3
from datetime import datetime, timedelta, timezone
from botocore.exceptions import ClientError

def delete_old_snapshots(region_name='ca-central-1'):
    ec2 = boto3.client('ec2', region_name=region_name)
    thirty_days_ago_utc = datetime.now(timezone.utc) - timedelta(days=30)
    paginator = ec2.get_paginator('describe_snapshots')

    old_snapshots_found = False

    for page in paginator.paginate(OwnerIds=['self']):
        for snapshot in page['Snapshots']:
            snapshot_time = snapshot['StartTime'].astimezone(timezone.utc).replace(tzinfo=timezone.utc)
            print(f"Found snapshot {snapshot['SnapshotId']} with creation time {snapshot_time}. Current UTC time is {datetime.now(timezone.utc)}.")

            if snapshot_time < thirty_days_ago_utc:
                old_snapshots_found = True
                print(f"Attempting to delete snapshot {snapshot['SnapshotId']}")
                try:
                    ec2.delete_snapshot(SnapshotId=snapshot['SnapshotId'])
                    print(f"Deleted snapshot {snapshot['SnapshotId']}")
                except ClientError as e:
                    if e.response['Error']['Code'] == 'InvalidSnapshot.InUse':
                        print(f"Skipping snapshot {snapshot['SnapshotId']} as it is in use by an AMI.")
                    else:
                        print(f"Error deleting snapshot {snapshot['SnapshotId']}. Error: {str(e)}")

    if not old_snapshots_found:
        print("No snapshots found which are older than 30 days.")

if __name__ == '__main__':
    delete_old_snapshots()

