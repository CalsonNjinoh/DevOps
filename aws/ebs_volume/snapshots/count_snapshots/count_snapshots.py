import boto3
from datetime import datetime, timedelta

def list_old_snapshots(region_name='ca-central-1'):
    ec2 = boto3.client('ec2', region_name=region_name)
    thirty_days_ago = datetime.now() - timedelta(days=30)
    paginator = ec2.get_paginator('describe_snapshots')

    for page in paginator.paginate(OwnerIds=['self']):
        for snapshot in page['Snapshots']:
            snapshot_time = snapshot['StartTime'].replace(tzinfo=None)
            if snapshot_time < thirty_days_ago:
                print(f"Snapshot ID: {snapshot['SnapshotId']} | Date: {snapshot_time}")

if __name__ == '__main__':
    list_old_snapshots()

