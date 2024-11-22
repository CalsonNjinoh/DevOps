output "secrets_policy" {
  value = one(aws_iam_policy.secrets_policy[*].arn)
}

output "backup_policy" {
  value = one(aws_iam_policy.backup_write_policy[*].arn)
}

output "chime_policy" {
  value = one(aws_iam_policy.chime_policy[*].arn)
}

output "workflow_logs_policy" {
  value = one(aws_iam_policy.workflow_logs_policy[*].arn)
}

output "atlas_policy" {
  value = one(aws_iam_policy.atlas_policy[*].arn)
}

output "cloudwatch_log_policy" {
  value = one(aws_iam_policy.cloudwatch_log[*].arn)
}

output "cloudwatch_agent_policy" {
  value = one(aws_iam_policy.cloudwatch_agent_policy[*].arn)
}

output "s3_data_uploads_us_arn" {
  value = one(aws_iam_policy.s3_data_uploads_us[*].arn)
}

output "systems_manager_get_parameters_arn" {
  value = one(aws_iam_policy.systems_manager_get_parameters[*].arn)
}

output "assume_cross_account_role_policy_arn" {
  value = one(aws_iam_policy.assume_cross_account_role_policy[*].arn)
}

output "vpc_flow_logs_policy_arn" {
  value       = aws_iam_policy.vpc_flow_logs_policy[0].arn
}
