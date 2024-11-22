variable "name" {
  type        = string
  description = "Name of environment"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}

variable "cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "enable_public_ipv6" {
  type        = bool
  description = "Enable public IPv6"
  default     = false
}

variable "public_subnets_ipv6" {
  type        = list(string)
  description = "IPv6 CIDR block for VPC"
  default     = []
}

variable "public_subnets" {
  type        = list(string)
  description = "Public Subnets"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private Subnets"
}

variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}
variable "centralized_vpc_flow_logs_bucket_arn" {
  type        = string
  description = "ARN of the centralized S3 bucket for VPC flow logs"
}

variable "custom_private_acl_ingress" {
  type        = list(map(string))
  description = "Custom private ACL rules"
  default     = []
}

variable "custom_private_acl_egress" {
  type        = list(map(string))
  description = "Custom private ACL rules"
  default     = []
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames"
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use a single NAT Gateway"
  default     = false
}

variable "one_nat_gateway_per_az" {
  type        = bool
  description = "Use one NAT Gateway per AZ"
  default     = false
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for VPC Flow Logs"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "The number of days to retain log events in the specified log group"
  type        = number
}

variable "max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record"
  type        = number
}

variable "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs"
  type        = string
  default     = ""
}

variable "vpc_flow_logs_role_arn" {
  description = "The ARN of the IAM role for VPC Flow Logs"
  type        = string
}
