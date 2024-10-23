variable "region" {
  type        = string
  description = "Name of the region in which cluster need to be created"
  default     = "us-east-1"
}

variable "name" {
  type        = string
  description = "Name of environment"
  default     = "name"
}

variable "bucket_name" {
  type        = string
  description = "Name of environment"
  default     = "name"
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
	description = "Centralized VPC Flow Logs Bucket ARN"
	default     = ""
}

variable "ORG" {
  description = "The organization ID"
  type        = string
}

variable "BUCKETORG" {
  description = "The bucket organization ID"
  type        = string
}

variable "WORKFLOW" {
  description = "The workflow ID"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "lambda_functions" {
  description = "Map of Lambda functions with their configurations"
  type = map(object({
    handler                = string
    runtime                = string
    role_arn               = string
    timeout                = number
    source_dir             = string
    environment_variables  = map(string)
    enable_eventbridge     = bool
    eventbridge_rule_name  = string
    eventbridge_schedule_expression = string
  }))
  default = {
    function1 = {
      handler                = "src/index.handler"
      runtime                = "nodejs16.x"
      role_arn               = ""
      timeout                = 899
      source_dir             = "lambda_sources/function1"
      environment_variables  = {
        MONGO     = ""
        ENV       = "dev"
        BUCKET    = ""
        ORG       = ""
        BUCKETORG = ""
        WORKFLOW  = ""
      }
      enable_eventbridge     = true
      eventbridge_rule_name  = "export-9meters-scheduler-dev"
      eventbridge_schedule_expression = "cron(59 23 ? * SUN *)"
    }
  }
}


/*variable "peer_vpc_id" {
  description = "The ID of the peer VPC"
  type        = string
}

variable "peer_owner_id" {
  description = "The AWS account ID of the peer VPC owner"
  type        = string
}

variable "peer_cidr_block" {
  description = "The CIDR block of the peer VPC"
  type        = string
}*/

variable "lambda_to_update" {
  description = "The name of the lambda function to update"
  type        = string
  default     = ""
}
