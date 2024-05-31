output "node_role_arn" {
  description = "ARN of the IAM role for EKS nodes"
  value       = aws_iam_role.eks-node-role.arn
}
