variable "region" {
  type        = string
  description = "Name of the region in which cluster need to be created"
  default = "us-east-1"
}

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
//variable "centralized_vpc_flow_logs_bucket_arn" {
  //type        = string
  //description = "ARN of the centralized S3 bucket for VPC flow logs"
//}
variable "price_class" {
  type        = string
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  default     = "PriceClass_200"  
}
