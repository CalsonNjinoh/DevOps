output "node_group_name" {
  description = "Name of the EKS node group"
  value       = aws_eks_node_group.eks-nodegroup.node_group_name
}

output "node_group_arn" {
  description = "ARN of the EKS node group"
  value       = aws_eks_node_group.eks-nodegroup.arn
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.eks-nodegroup.status
}
