
/*variable "waf_name" {
  description = "Name of the WAF"
  type        = string
}*/

/*variable "description" {
  description = "Description of the WAF"
  type        = string
}*/

variable "rules" {
  description = "List of WAF rules"
  type        = list(map(string))
}

variable "alb_arn" {
  description = "ARN of the ALB"
  type        = string
}

variable "environment" {
  description = "The environment for which to create resources (e.g., dev, prod)"
  type        = string
}

variable "regions" {
  description = "List of regions where WAF rules should be applied"
  type        = list(string)
}


variable "whitelist_ip_addresses" {
  type = map(list(string))
}

variable "blacklist_ip_addresses_per_region" {
  description = "Map of regions to the list of IP addresses to blacklist"
  type        = map(list(string))

}

variable "create_blacklist_rule" {
  description = "Map of regions to boolean indicating whether to create a blacklist rule"
  type        = map(bool)
}


variable "create_files_rule" {
  description = "Map of regions to boolean indicating whether to create a files rule"
  type        = map(bool)
  
}

variable "create_many_file_requests_rule" {
  description = "Map of regions to boolean indicating whether to create a many file requests rule"
  type        = map(bool)
  
}




###################
# EBS Variables
####################

/*variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}*/


variable "cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "0.0.0.0/0"
}

variable "name" {
  type        = string
  description = "Name of environment"
  default     = "name"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = []
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

variable "region" {
  type        = string
  description = "Region"
  default     = "ca-central-1"
  
}

variable "centralized_vpc_flow_logs_bucket_arn" {
  type        = string
  description = "ARN of the centralized S3 bucket for VPC flow logs"
  default     = ""
  
}

variable "env" {
	type        = string
	description = "Region in which Iam Policy is been built"
	default     = ""
}

