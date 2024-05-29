output "endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}

output "cluster_id" {
  value = aws_eks_cluster.eks-cluster.id
}

output "oidc_provider_arn" {
  value = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}


output "additional_securitygroup" {
  value       = aws_security_group.eks-sg.id
  description = "EKS additional security group that allows requests from worker nodes"
}

