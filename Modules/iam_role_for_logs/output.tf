output "iam_role_arn" {
  description = "ARN of the IAM role for VPC flow logs."
  value       = aws_iam_role.vpc_flow_log_role.arn
}
