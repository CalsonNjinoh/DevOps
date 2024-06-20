output "cluster_role_arn" {
  description = "ARN of the IAM role for EKS cluster"
  value       = aws_iam_role.eks-role.arn
}
