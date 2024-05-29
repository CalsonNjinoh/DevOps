resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-role.arn

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids         = var.eks_subnets
    security_group_ids = [aws_security_group.eks-sg.id]
    endpoint_public_access  = false
    endpoint_private_access = true
  }

  kubernetes_network_config {
    ip_family = "ipv6"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-policy,
    aws_iam_role_policy_attachment.eks-cluster-policy-2,
  ]
  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}"
  }
}

