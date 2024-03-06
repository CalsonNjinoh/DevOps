variable "sns_topic_name" {
  description = "The name of the SNS topic"
  type        = string
}

variable "subscription_email_addresses" {
  description = "List of email addresses to subscribe to the SNS topic"
  type        = list(string)
  default     = []
}
