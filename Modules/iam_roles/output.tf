output "ssm_role_arn" {
  value     = var.create_ssm_role ? aws_iam_role.ssm_role[0].arn : ""
  sensitive = false
}
output "ssm_instance_profile_name" {
  value = var.create_ssm_role ? aws_iam_instance_profile.ssm_instance_profile[0].name : ""
}

