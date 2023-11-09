variable "region" {
  type        = string
  description = "Name of the region in which cluster need to be created"
  default     = "ca-central-1"
}
variable "public_domain_name" {
  description = "The domain name for the public hosted zone."
  type        = string
}
//variable "private_domain_name" {
  //description = "The domain name for the private hosted zone."
  //type        = string
//}

variable "vpc_id" {
  description = "The VPC ID associated with the hosted zones."
  type        = string
}
variable "public_records" {
  description = "Map of DNS records to create in the public hosted zone."
  type        = map(any)
  default     = {}
}
//variable "private_records" {
  //description = "Map of DNS records to create in the private hosted zone."
  //type        = map(any)
  //default     = {}
//}

# Jenkins Configuration

variable "name" {
  type        = string
  description = "Name of environment"
  default     = "development"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = []
}

variable "cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "0.0.0.0/0"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public Subnets"
  default     = []
}

variable "private_subnets" {
  type        = list(string)
  description = "Private Subnets"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}

variable "key_path" {
  type        = string
  description = "Path to SSH public key"
  default     = ""
}
variable "centralized_vpc_flow_logs_bucket_arn" {
  type        = string
  description = "ARN of the centralized S3 bucket for VPC flow logs"
}
