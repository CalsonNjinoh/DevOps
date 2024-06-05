resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-eks-sg"
  description = "Cluster Communication with worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.cluster_name}-eks-sg"
  }
}

resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "Worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.cluster_name}-nodes-sg"
  }
}

resource "aws_security_group_rule" "cluster_inbound_https" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_inbound_http" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  type                     = "egress"
}
