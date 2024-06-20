variable "cluster_name" {
    description = "The name of the EKS cluster"
    type        = string
    }

variable "vpc_id" {
    description = "The VPC ID where the security group will be created"
    type        = string
    }

variable "eks_cluster_security_group_id" {
    description = "The ID of the security group for the EKS cluster"
    type        = string
    }
