variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}
variable "lambda_package" {
  description = "The location of the Lambda function code package"
  type        = string
}
variable "eventbridge_schedule_expression" {
  description = "The schedule expression for the EventBridge rule (cron or rate)"
  type        = string
}

variable "lambda_functions" {
  description = "Map of Lambda functions with their configurations"
  type = map(object({
    source_dir              = string
    run_yarn                = bool
    compile_typescript      = bool
    handler                 = string
    runtime                 = string
    role_arn                = string
    timeout                 = number
    environment_variables   = map(string)
    enable_eventbridge      = bool
    eventbridge_rule_name   = string
    eventbridge_schedule_expression = string
    bucket                  = string
  }))
}

variable "security_group_ids" {
  description = "List of security group IDs for the Lambda functions"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Lambda functions"
  type        = list(string)
}
