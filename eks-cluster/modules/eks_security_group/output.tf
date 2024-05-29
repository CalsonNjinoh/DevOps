output "additional_securitygroup" {
  value       = aws_security_group.eks-sg.id
  description = "EKS additional security group that allows requests from worker nodes"
}

