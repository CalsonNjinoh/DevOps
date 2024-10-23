variable "create_ssm_role" {
  description = "Whether to create the SSM role"
  type        = bool
  default     = false
}

variable "OU" {
  description = "OU account Number"
  default     = ""
  type        = string
}

variable "create_backend_role" {
  description = "Whether to create the Secrets Manager role"
  type        = bool
  default     = false
}

variable "create_backup_role" {
  description = "Whether to create the Backup role"
  type        = bool
  default     = false
}

variable "backup_role_policy" {
  description = "Policy for the backup role"
  type        = string
  default     = ""
}

variable "policies_for_backend_role" {
  description = "Policies required for backend services"
  type = list(object({
    policy_arn = string
  }))
  default = []
}

variable "backup_role_policies" {
  description = "Policies required for backup services"
  type = list(object({
    policy_arn = string
  }))
  default = []
}

variable "ssm_role_policies" {
  description = "Policies required for backup services"
  type = list(object({
    policy_arn = string
  }))
  default = []
}

/*variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}*/

variable "create_lambda_basic_execution" {
  description = "Whether to attach the AWSLambdaBasicExecutionRole policy"
  type        = bool
  default     = false
}

variable "create_ec2_full_access" {
  description = "Whether to attach the AmazonEC2FullAccess policy"
  type        = bool
  default     = false
}

variable "create_eventbridge_full_access" {
  description = "Whether to attach the AmazonEventBridgeFullAccess policy"
  type        = bool
  default     = false
}

variable "create_lambda_exec_role" {
  description = "Flag to indicate if the Lambda execution role should be created"
  type        = bool
  default     = false
}

variable "create_production_role" {
  description = "Flag to indicate if the production role should be created"
  type        = bool
  default     = false
}

variable "policies_for_production_role" {
  description = "Policies required for the production role"
  type = list(object({
    policy_arn = string
  }))
  default = []
}

variable "policies_for_lambda_exec_role" {
  description = "Policies required for the Lambda execution role"
  type = list(object({
    policy_arn = string
  }))
  default = []
}
