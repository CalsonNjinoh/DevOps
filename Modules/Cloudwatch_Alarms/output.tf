
output "cloudwatch_alarm_arns" {
  value = { for k, v in aws_cloudwatch_metric_alarm.example : k => v.arn }
  description = "The ARNs of the CloudWatch alarms"
}

