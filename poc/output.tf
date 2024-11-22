output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "cloudwatch_log_group_arn" {
  value       = module.network.cloudwatch_log_group_arn
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs"
}
