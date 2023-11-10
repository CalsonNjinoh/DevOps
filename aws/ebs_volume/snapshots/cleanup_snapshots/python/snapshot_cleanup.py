import boto3
from datetime import datetime, timedelta, timezone
from botocore.exceptions import ClientError
def delete_old_snapshots(region_name, results):
    ec2 = boto3.client('ec2', region_name=region_name)
    thirty_days_ago_utc = datetime.now(timezone.utc) - timedelta(days=30)
    paginator = ec2.get_paginator('describe_snapshots')
    deleted_snapshots_count = 0
    skipped_snapshots_count = 0
    for page in paginator.paginate(OwnerIds=['self']):
        for snapshot in page['Snapshots']:
            snapshot_time = snapshot['StartTime'].astimezone(timezone.utc).replace(tzinfo=timezone.utc)
            print(f"Found snapshot {snapshot['SnapshotId']} with creation time {snapshot_time}. Current UTC time is {datetime.now(timezone.utc)}.")
            if snapshot_time < thirty_days_ago_utc:
                print(f"Attempting to delete snapshot {snapshot['SnapshotId']}")
                try:
                    ec2.delete_snapshot(SnapshotId=snapshot['SnapshotId'])
                    print(f"Deleted snapshot {snapshot['SnapshotId']}")
                    deleted_snapshots_count += 1
                except ClientError as e:
                    if e.response['Error']['Code'] == 'InvalidSnapshot.InUse':
                        print(f"Skipping snapshot {snapshot['SnapshotId']} as it is in use by an AMI.")
                        skipped_snapshots_count += 1
                    else:
                        print(f"Error deleting snapshot {snapshot['SnapshotId']}. Error: {str(e)}")
    results[region_name] = {'deleted': deleted_snapshots_count, 'skipped': skipped_snapshots_count}
if __name__ == '__main__':
    REGIONS = ['ca-central-1', 'us-east-1', 'eu-west-2']  # Add/Update regions as needed
    results = {}
    for region in REGIONS:
        print(f"Processing region: {region}")
        delete_old_snapshots(region_name=region, results=results)
    for region, counts in results.items():
        print(f"Deleted snapshots from {region}: {counts['deleted']}")
        print(f"Skipped snapshots from {region}: {counts['skipped']}")
