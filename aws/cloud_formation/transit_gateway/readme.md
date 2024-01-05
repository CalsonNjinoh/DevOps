## Documentation: AWS CloudFormation for Transit Gateway Setup

## Overview

This document describes the AWS CloudFormation template used to set up a Transit Gateway in an AWS account (referred to as Account 

A), attach it to a specific VPC, and share it with another AWS account (Account B). This enables resources in different accounts to communicate securely and efficiently.

## Template Description

## The CloudFormation template creates the following resources:

## Transit Gateway: 
A regional resource that connects VPCs and on-premises networks.
Transit Gateway Attachment: Attaches the Transit Gateway to a specific VPC in Account A.

## Resource Share: 

Shares the Transit Gateway with Account B using AWS Resource Access Manager (RAM).
## Route: 

Adds a route to the route table of the VPC, directing traffic to the Development VPC's CIDR block through the Transit Gateway.

## Parameters

## AetonixVPCID: 
The ID of the VPC in Account A where the Transit Gateway is attached.
## AetonixRouteTableID: 
The ID of the route table where the route to the Development VPC will be added.
## AetonixSubnetIDs: 
 A list of subnet IDs in the Aetonix VPC for the Transit Gateway attachment.
## SharedAccountId: 
The AWS Account ID of Account B with which you want to share the Transit Gateway.
## DevelopmentVPCCIDR:
 The CIDR block for the Development VPC in Account B.
Resources

## MyTransitGateway

Type: AWS::EC2::TransitGateway
Description: Creates a Transit Gateway with specified properties for DNS support, VPN ECMP support, and route table association and propagation.
TransitGatewayAttachmentAetonix
Type: AWS::EC2::TransitGatewayVpcAttachment
Description: Attaches the Transit Gateway to the specified VPC and subnets in Account A.
TransitGatewayResourceShare
Type: AWS::RAM::ResourceShare
Description: Shares the Transit Gateway with Account B, allowing resources in Account B to be connected to the Transit Gateway.
RouteToDevelopmentVPC
Type: AWS::EC2::Route
Description: Adds a route to the specified route table, directing traffic destined for the Development VPC's CIDR block through the Transit Gateway.
Outputs

TransitGatewayID: The ID of the created Transit Gateway.
TransitGatewayAttachmentAetonixID: The ID of the Transit Gateway attachment to the Aetonix VPC.
TransitGatewayResourceShareID: The ID of the Transit Gateway Resource Share.
Usage

## Usage Instructions

## Prerequisites

- Install the AWS Command Line Interface (CLI).
- Configure the AWS CLI with credentials that have the necessary permissions.
- Verify that you have the IDs and CIDR blocks required for the parameters.
- Validate the Template
- Before deploying, validate the CloudFormation template to ensure it's free of syntax errors.

aws cloudformation validate-template --template-body file://path_to_your_template.yaml

Replace path_to_your_template.yaml with the actual file path of your CloudFormation template.

## Deploy the Stack
Deploy the stack using the following AWS CLI command. Replace the parameter values with those appropriate for your environment.

aws cloudformation create-stack --stack-name MyTransitGatewaySetup --template-body file://path_to_your_template.yaml 

Note: if there are run time paramaters you will need to pass them

## Monitor Stack Creation

Monitor the progress of your stack creation using the AWS Management Console, or use the following CLI command:


aws cloudformation describe-stacks --stack-name MyTransitGatewaySetup

Look for the StackStatus field in the output to see if the stack was created successfully.




Ensure you have the necessary permissions in both AWS accounts.
Validate the template using the AWS CLI or Management Console.
Deploy the template via the AWS Management Console or CLI, providing the required parameters.
Monitor the stack creation process and verify the resources once created.
Maintenance and Updates

Regularly review and update the template and resources for any new AWS features or improvements.
Monitor the usage and performance of the Transit Gateway and associated resources.
Update documentation with any changes made to the template or resources.


Account B 