variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS node group"
  type        = list(string)
}

variable "instance_types" {
  description = "List of EC2 instance types for the EKS node group"
  type        = list(string)
}

variable "scaling_configuration" {
  description = "Scaling configuration for the EKS node group"
  type        = map(string)
  default     = {
    min_size        = 3
    desired_size    = 5
    max_size        = 6
    max_unavailable = 1
  }
}

variable "ec2_ssh_key_name" {
  description = "Name of the EC2 SSH key pair"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "security_group_id" {
  description = "Security group ID for the EKS node group"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for the EKS nodes"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster and node group are deployed"
  type        = string
}
