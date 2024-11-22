output "ssm_role_arn" {
  value     = var.create_ssm_role ? aws_iam_role.ssm_role[0].arn : ""
  sensitive = false
}
output "ssm_instance_profile_name" {
  value = var.create_ssm_role ? aws_iam_instance_profile.ssm_instance_profile[0].name : ""
}

output "backend_role_arn" {
  value     = var.create_backend_role ? aws_iam_role.backend_role[0].arn : ""
  sensitive = false
}

output "backend_instance_profile_name" {
  value = var.create_backend_role ? aws_iam_instance_profile.secrets_instance_profile[0].name : ""
}

output "backup_instance_profile_name" {
  value = var.create_backup_role ? aws_iam_instance_profile.backup_instance_profile[0].name : ""
}

output "lambda_role_name" {
  value = var.create_lambda_exec_role ? aws_iam_role.lambda_exec[0].name : ""
}

output "lambda_role_arn" {
  value = var.create_lambda_exec_role ? aws_iam_role.lambda_exec[0].arn : ""
}

/*output "vpc_flow_logs_role_arn" {
  value = aws_iam_role.vpc_flow_logs_role[0].arn
}*/

output "vpc_flow_logs_role_arn" {
  value = var.create_vpc_flow_logs_role ? aws_iam_role.vpc_flow_logs_role[0].arn : ""
}


