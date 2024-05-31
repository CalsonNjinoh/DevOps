resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids         = var.eks_subnets
    security_group_ids = [var.security_group_id]
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  kubernetes_network_config {
    ip_family = "ipv6"
  }
}

  /*depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-policy,
    aws_iam_role_policy_attachment.eks-cluster-policy-2,
  ]
  
   provisioner "local-exec" {
    command = "aws eks --region ${var.region} wait cluster-active --name ${var.cluster_name} && aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}"
  }
}
*/