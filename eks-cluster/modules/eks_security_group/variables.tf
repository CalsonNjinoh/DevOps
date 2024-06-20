variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
}
