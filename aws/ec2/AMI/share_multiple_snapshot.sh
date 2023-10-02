#!/bin/bash

#####Variables#####
####################

# Replace with your source AWS account ID
SOURCE_ACCOUNT="370308050188"

# Replace with the destination AWS account ID
DEST_ACCOUNT="816037198234"

# Add multiple EC2 instance IDs to the array
INSTANCE_IDS=("i-0dfba4e367311b7f6" "i-0cee11319a62ac6d5")

for INSTANCE_ID in "${INSTANCE_IDS[@]}"; do
    # Fetch the name of the instance using the "Name" tag
    INSTANCE_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --query 'Tags[0].Value' --output text)
    
    # If the instance doesn't have a name, set a default
    if [ "$INSTANCE_NAME" == "None" ] || [ -z "$INSTANCE_NAME" ]; then
        INSTANCE_NAME="UnnamedInstance"
    fi

    AMI_NAME="$INSTANCE_NAME-AMI-$(date +%Y-%m-%d)"  # This gives the AMI a name with the instance Name and today's date

    #####Create AMI######
    ######################

    echo "Creating AMI for instance $INSTANCE_ID..."
    AMI_ID=$(aws ec2 create-image --instance-id $INSTANCE_ID --name "$AMI_NAME" --no-reboot --query 'ImageId' --output text)
    echo "AMI creation initiated. AMI ID: $AMI_ID"

    ###Wait for AMI to be available####
    ###################################

    echo "Waiting for AMI to be in 'available' state..."
    aws ec2 wait image-available --image-ids $AMI_ID
    echo "AMI for $INSTANCE_ID is now available."

    ### Extract the snapshot ID associated with the AMI ###
    #######################################################

    SNAPSHOT_ID=$(aws ec2 describe-images --image-ids $AMI_ID --query "Images[0].BlockDeviceMappings[0].Ebs.SnapshotId" --output text)
    echo "Snapshot ID associated with AMI of $INSTANCE_ID: $SNAPSHOT_ID"

    ### Modify AMI permissions to share with another account ###
    ############################################################

    echo "Sharing AMI with account $DEST_ACCOUNT..."
    aws ec2 modify-image-attribute --image-id $AMI_ID --launch-permission "Add=[{UserId=$DEST_ACCOUNT}]"

    ### Share the associated snapshot with the destination account ###
    ##################################################################

    echo "Sharing snapshot with account $DEST_ACCOUNT..."
    aws ec2 modify-snapshot-attribute --snapshot-id $SNAPSHOT_ID --create-volume-permission "Add=[{UserId=$DEST_ACCOUNT}]"

    echo "AMI and snapshot for $INSTANCE_ID shared successfully!"
done

