variable "alarm_metrics" {
  description = "A map of metrics to create alarms for"
  type = map(object({
    metric_name        = string
    namespace          = string
    statistic          = string
    threshold          = number
    evaluation_periods = number
    period             = number
    // Add other necessary properties
  }))
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm actions"
  type        = string
}

