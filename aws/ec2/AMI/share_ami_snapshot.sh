#!/bin/bash

#####Variables#####
####################

INSTANCE_ID="i-0dfba4e367311b7f6"  # Replace with your EC2 instance ID
SOURCE_ACCOUNT="370308050188"  # Replace with your source AWS account ID
DEST_ACCOUNT="816037198234"  # Replace with the destination AWS account ID
AMI_NAME="Jenkins-AMI-$(date +%Y-%m-%d)"  # This gives the AMI a name with today's date

#####Create AMI######
######################

echo "Creating AMI for instance $INSTANCE_ID..."
AMI_ID=$(aws ec2 create-image --instance-id $INSTANCE_ID --name "$AMI_NAME" --no-reboot --query 'ImageId' --output text)
echo "AMI creation initiated. AMI ID: $AMI_ID"

###Wait for AMI to be available####
###################################

echo "Waiting for AMI to be in 'available' state..."
aws ec2 wait image-available --image-ids $AMI_ID
echo "AMI is now available."

### Extract the snapshot ID associated with the AMI ###
#######################################################

SNAPSHOT_ID=$(aws ec2 describe-images --image-ids $AMI_ID --query "Images[0].BlockDeviceMappings[0].Ebs.SnapshotId" --output text)
echo "Snapshot ID associated with AMI: $SNAPSHOT_ID"

### Modify AMI permissions to share with another account ###
############################################################

echo "Sharing AMI with account $DEST_ACCOUNT..."
aws ec2 modify-image-attribute --image-id $AMI_ID --launch-permission "Add=[{UserId=$DEST_ACCOUNT}]"

### Share the associated snapshot with the destination account ###
##################################################################

echo "Sharing snapshot with account $DEST_ACCOUNT..."
aws ec2 modify-snapshot-attribute --snapshot-id $SNAPSHOT_ID --create-volume-permission "Add=[{UserId=$DEST_ACCOUNT}]"

echo "AMI and snapshot shared successfully!"

