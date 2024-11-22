variable "environment" {
  description = "The environment name (e.g., dev, prod)."
  type        = string
}
variable "sns_topic_arn" {
  description = "The ARN of the existing SNS topic for notifications."
  type        = string
}
variable "enable_guardduty" {
  description = "Enable GuardDuty notifications."
  type        = bool
}


variable "rules_config" {
  description = "Configuration for each EventBridge rule and its target"
  type = list(object({
    cron                = string
    lambda_function_arn = string
    rule_name           = string
    rule_description    = string
  }))
}


variable "excluded_rule_names" {
  description = "List of rule names to exclude from deployment"
  type        = list(string)
  default     = []
}

variable "schedule_name" {
  description = "Name of the EventBridge schedule"
  default     = "my-lambda-scheduler"
}

variable "schedule_pattern" {
  description = "The schedule expression (rate or cron)"
  default     = "rate(5 minutes)"  
}

variable "function_name" {
  type = string
  description = "Name of the Lambda function"
}

variable "handler" {
  type = string
  description = "The Lambda function handler (e.g., index.handler)"
}

variable "runtime" {
  type = string
  description = "The runtime environment for the Lambda function (e.g., python3.8)"
}

variable "environment_variables" {
  type = map(string)
  description = "Environment variables for the Lambda function"
  default = {}
}


variable "create_eventbridge_scheduler" {
  description = "Whether to create EventBridge Scheduler resources"
  type        = bool
  default     = false
}

variable "schedule_description" {
  description = "Description of the EventBridge Scheduler"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to be invoked by the EventBridge Scheduler"
  type        = string
}

variable "create_lambda_resources" {
  description = "Whether to create Lambda resources"
  type        = bool
  default     = false
}
