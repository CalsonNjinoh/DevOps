#!/bin/bash

# Array of volume IDs
declare -a volume_ids=("vol-00e9664792c6b4fe4" "vol-0a5765714684fd704" "vol-0d2c5f42dff3f0334" "vol-0667311ba548b87c7" "vol-026c087b2a51a4b6b" "vol-0857fb5ae9c7a2fd7")

# AWS region
region="ca-central-1"

for volume_id in "${volume_ids[@]}"; do
  echo "Processing volume: $volume_id"

  # Get the instance id to which the volume is attached to
  echo "Fetching instance ID for volume $volume_id..."
  instance_id=$(aws ec2 describe-volumes --volume-ids "$volume_id" --region "$region" --query 'Volumes[0].Attachments[0].InstanceId' --output text)
  echo "Volume $volume_id is attached to instance ID: $instance_id"

  # Get the instance name from the instance id
  echo "Fetching instance name for instance ID $instance_id..."
  instance_name=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" "Name=key,Values=Name" --region "$region" --query 'Tags[0].Value' --output text)
  echo "Instance ID $instance_id has the name: $instance_name"

  # Get the availability zone of the volume
  echo "Fetching availability zone for volume $volume_id..."
  availability_zone=$(aws ec2 describe-volumes --volume-ids "$volume_id" --region "$region" --query 'Volumes[0].AvailabilityZone' --output text)
  echo "Volume $volume_id is located in availability zone: $availability_zone"

  # Create snapshot
  echo "Creating snapshot for volume $volume_id..."
  snapshot_id=$(aws ec2 create-snapshot --volume-id "$volume_id" --region "$region" --description "Snapshot for $volume_id" --tag-specifications "ResourceType=snapshot,Tags=[{Key=Name,Value=$instance_name}]" --query 'SnapshotId' --output text)
  echo "Created snapshot $snapshot_id for volume $volume_id."

  # Wait until the snapshot is completed
  echo "Waiting for snapshot $snapshot_id to complete..."
  aws ec2 wait snapshot-completed --snapshot-ids "$snapshot_id" --region "$region"
  echo "Snapshot $snapshot_id is ready."

  # Create encrypted volume from the snapshot
  echo "Creating encrypted volume from snapshot $snapshot_id..."
  encrypted_volume_id=$(aws ec2 create-volume --snapshot-id "$snapshot_id" --availability-zone "$availability_zone" --region "$region" --encrypted --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$instance_name}]" --query 'VolumeId' --output text)
  echo "Created encrypted volume $encrypted_volume_id from snapshot $snapshot_id."
  
  echo "----------------------------------------"
done
