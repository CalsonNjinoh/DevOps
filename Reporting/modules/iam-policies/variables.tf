variable "secrets_arn" {
  type    = string
  default = ""
}

variable "backup_bucket_arn" {
  type        = string
  description = "ARN of the backup bucket"
  default     = ""
}

variable "workflow_logs_arn" {
  type        = string
  description = "ARN of the workflow logs log group"
  default     = ""
}

variable "create_chime_policy" {
  type        = bool
  description = "Create Chime policy"
  default     = false
}

variable "create_secrets_policy" {
  type        = bool
  description = "Create Secrets policy"
  default     = false
}

variable "create_backup_policy" {
  type        = bool
  description = "Create Backup policy"
  default     = false
}

variable "create_workflow_logs_policy" {
  type        = bool
  description = "Create Workflow logs policy"
  default     = false
}

variable "secrets_encryption_key_arn" {
  type        = string
  description = "ARN of the KMS key for secrets encryption"
  default     = ""
}

variable "create_atlas_policy" {
  type        = bool
  description = "Create Atlas policy"
  default     = false
}

variable "atlas_kms_key_arn" {
  type        = string
  description = "ARN of the KMS key for Atlas"
  default     = ""
}

variable "create_cloudwatch_log_policy" {
  type        = bool
  description = "Create cloudwatch log policy"
  default     = false
}

variable "create_cloudwatch_agent_policy" {
  type        = bool
  description = "Create cloudwatch agent policy"
  default     = false
}

variable "cloudwatch_agent_role" {
  type        = string
  description = "ARN of the Cloudwatch role"
  default     = ""
}

variable "create_s3_data_uploads_us_policy" {
  description = "Whether to create the S3 data uploads policy"
  type        = bool
  default     = false
}

variable "create_systems_manager_get_parameters_policy" {
  description = "Whether to create the Systems Manager get parameters policy"
  type        = bool
  default     = false
}

variable "create_assume_cross_account_role_policy" {
  description = "Whether to create the assume cross-account role policy"
  type        = bool
  default     = false
}

variable "env" {
	type        = string
	description = "Region in which Iam Policy is been built"
	default     = ""

}


variable "firebase_arn" {
	type        = string
	description = "ARN of the Firebase secret"
	default     = ""
}
