output "dlm_lifecycle_policy_id" {
  description = "The ID of the DLM lifecycle policy"
  value       = aws_dlm_lifecycle_policy.ebs_lifecycle.id
}
output "ebs_lifecycle_role_arn" {
  description = "The ARN of the IAM role used by the DLM lifecycle policy"
  value       = aws_iam_role.ebs_lifecycle_role.arn
  
}
