#!/bin/bash

# Configuration
EBS_VOLUME_IDS=("vol-0a5765714684fd704" "vol-03a9a99ab8a623699")
REGION="ca-central-1"
AVAILABILITY_ZONE="ca-central-1b"

# Wait times
WAIT_INTERVAL=60  # Check every 60 seconds
MAX_WAIT_TIME=3600  # Maximum wait time of 1 hour for both snapshot and volume

create_snapshot() {
  local volume_id=$1
  echo "Creating snapshot from volume $volume_id..."
  local snapshot_id=$(aws ec2 create-snapshot --region $REGION --volume-id $volume_id --description 'Snapshot created by script' --query 'SnapshotId' --output text)
  echo "Snapshot created with ID: $snapshot_id"
  
  local elapsed_time=0
  while [ $elapsed_time -le $MAX_WAIT_TIME ]; do
    local status=$(aws ec2 describe-snapshots --region $REGION --snapshot-ids $snapshot_id --query 'Snapshots[0].State' --output text)
    echo "Current snapshot status: $status"
    if [ "$status" == "completed" ]; then
      echo "$snapshot_id"
      break
    fi
    sleep $WAIT_INTERVAL
    ((elapsed_time=elapsed_time+WAIT_INTERVAL))
  done
  
  if [ $elapsed_time > $MAX_WAIT_TIME ]; then
    echo "Max wait time exceeded for snapshot completion. Exiting."
    exit 1
  fi
}

create_encrypted_volume_from_snapshot() {
  local snapshot_id=$1
  echo "Creating encrypted volume from snapshot $snapshot_id..."
  local volume_id=$(aws ec2 create-volume --region $REGION --availability-zone $AVAILABILITY_ZONE --snapshot-id $snapshot_id --encrypted --query 'VolumeId' --output text)
  echo "Volume creation initiated with ID: $volume_id"

  local elapsed_time=0
  while [ $elapsed_time -le $MAX_WAIT_TIME ]; do
    local status=$(aws ec2 describe-volumes --region $REGION --volume-ids $volume_id --query 'Volumes[0].State' --output text)
    if [ "$status" == "available" ]; then
      echo "Volume is now available!"
      return
    fi
    sleep $WAIT_INTERVAL
    ((elapsed_time=elapsed_time+WAIT_INTERVAL))
  done
  
  echo "Max wait time exceeded for volume availability. Exiting."
  exit 1
}

# Main Execution
for volume_id in "${EBS_VOLUME_IDS[@]}"; do
  snapshot_id=$(create_snapshot $volume_id)
  create_encrypted_volume_from_snapshot $snapshot_id
done
