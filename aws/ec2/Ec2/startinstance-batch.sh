#!/bin/bash

##### Provide the AWS region and VPC ID #####
#############################################

AWS_Region='ca-central-1'
Dev_VPC_ID='vpc-0f2a0bf6dc289fbe9'
Jenkins_EC2_ID='i-0dfba4e367311b7f6'  # EC2 ID of the Jenkins server

##### Execute the AWS CLi to list all of the associated ec2 instances with the above VPC######
##############################################################################################

Instance_Ids=$(aws ec2 describe-instances --region "$AWS_Region" --filters "Name=vpc-id,Values=$Dev_VPC_ID" --query 'Reservations[].Instances[].InstanceId' --output text)

####### Loop through all of the instances associated with the VPC and start the respective EC2 instances, excluding the Jenkins server #####
###########################################################################################################################################

for ec2_id in $Instance_Ids; do
    if [ "$ec2_id" != "$Jenkins_EC2_ID" ]; then
        echo "Starting the Dev Instance: $ec2_id"
        aws ec2 start-instances --region "$AWS_Region" --instance-ids "$ec2_id"
    else
        echo "Skipping Jenkins server: $ec2_id"
    fi
done
