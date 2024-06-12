resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS worker nodes in the Cluster"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name                                                = "${var.cluster_name}-node-sg"
    "http://kubernetes.io/cluster/${var.cluster_name}-cluster" = "owned"
  }
}
resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "ingress"
}
resource "aws_security_group_rule" "nodes_cluster_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = var.eks_cluster_security_group_id
  to_port                  = 65535
  type                     = "ingress"
}
resource "aws_security_group_rule" "nodes_https_inbound" {
  description              = "Allow inbound HTTPS traffic from the control plane to worker nodes"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = var.eks_cluster_security_group_id
  type                     = "ingress"
}
