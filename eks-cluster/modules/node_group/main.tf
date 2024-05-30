resource "aws_eks_node_group" "eks-nodegroup" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types

  scaling_config {
    min_size     = lookup(var.scaling_configuration, "min_size", 3)
    desired_size = lookup(var.scaling_configuration, "desired_size", 5)
    max_size     = lookup(var.scaling_configuration, "max_size", 6)
  }

  update_config {
    max_unavailable = lookup(var.scaling_configuration, "max_unavailable", 1)
  }

  remote_access {
    ec2_ssh_key               = var.ec2_ssh_key_name
    source_security_group_ids = [var.security_group_id]
  }

  tags = merge({
    Name = var.cluster_name
  }, var.tags)
}
