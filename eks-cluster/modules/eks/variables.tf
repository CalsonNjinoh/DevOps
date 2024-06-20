variable "cluster_name" {
  type        = string
  description = "Name of the cluster for which nodes should be created"
  default = "Development-cluster"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID in which security group need to be created"
}

variable "eks_subnets" {
  type        = list(string)
  description = "List of public and private subnet ID's in which cluster need to be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet id's in which worked nodes should be created"
}

variable "instance_types" {
  type        = list(string)
  description = "Type of instances that need to be created as worked nodes"
}

variable "ec2_ssh_key_name" {
  type        = string
  description = "Name of the ssh key that need to be assigned to worker nodes"
}

variable "scaling_configuration" {
  type        = map(number)
  description = "Scaling configurations that need to be passed to auto-scaling group which creates worker nodes"
}


variable "tags" {
  type        = map(string)
  description = "Map of tags"
}

variable "region" {
  type        = string
  description = "Name of the region in which cluster need to be created"
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}
variable "cluster_role_arn" {
  description = "The ARN of the IAM role to associate with the EKS cluster"
  type        = string
}
variable "security_group_id" {
  description = "The ID of the security group to use for the EKS cluster"
  type        = string
}
