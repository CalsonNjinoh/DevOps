output "security_group_id" {
  value       = aws_security_group.eks_sg.id
  description = "EKS security group that allows requests from worker nodes"
}
