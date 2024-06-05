provider "aws" {
  region = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

locals {
  workspace = terraform.workspace == "default" ? "dev" : terraform.workspace
  tags      = var.env[local.workspace].tags
}

module "vpc" {
  source                  = "../../modules/vpc/"
  name                    = local.workspace
  vpc_cidr                = var.vpc_cidr
  tags                    = local.tags
  subnet_list             = var.subnet_list
  igw_name                = "${local.workspace}-igw-eks"
  public_routetable_name  = "${local.workspace}-public-route-table"
  private_routetable_name = "${local.workspace}-private-route-table"
  azs                     = var.azs
}

module "iam_cluster_roles" {
  source       = "../../modules/cluster_iam_roles"
  cluster_name = var.cluster_name
}

module "iam_node_roles" {
  source       = "../../modules/node_iam_roles"
  cluster_name = var.cluster_name
}

module "eks_security_group" {
  source       = "../../modules/eks_security_group"
  vpc_id       = module.vpc.vpc_id
  cluster_name = var.cluster_name
  tags         = local.tags
}

module "worker_nodes_security_group" {
  source                       = "../../modules/worker_nodes_security_group"
  vpc_id                       = module.vpc.vpc_id
  cluster_name                 = var.cluster_name
  eks_cluster_security_group_id = module.eks_security_group.eks_cluster_security_group_id
}

module "eks" {
  depends_on            = [module.vpc, aws_iam_role_policy_attachment.eks-cluster-policy, aws_iam_role_policy_attachment.eks-cluster-policy-2]
  source                = "../../modules/eks/"
  cluster_name          = var.cluster_name
  vpc_id                = module.vpc.vpc_id
  eks_subnets           = module.vpc.private_subnet_id
  subnet_ids            = module.vpc.private_subnet_id
  ec2_ssh_key_name      = var.ec2_ssh_key_name
  instance_types        = [var.instance_type]
  scaling_configuration = var.scaling_configuration
  region                = var.region
  aws_auth_users        = var.aws_auth_users
  cluster_role_arn      = aws_iam_role.eks_cluster_role.arn
  security_group_id     = module.eks_security_group.eks_cluster_security_group_id
  tags                  = local.tags
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy-2" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

module "node_group" {
  source                = "../../modules/node_group/"
  cluster_name          = var.cluster_name
  subnet_ids            = module.vpc.private_subnet_id
  instance_types        = [var.instance_type]
  scaling_configuration = var.scaling_configuration
  ec2_ssh_key_name      = var.ec2_ssh_key_name
  security_group_id     = module.worker_nodes_security_group.security_group_id
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  tags                  = local.tags
  node_role_arn         = module.iam_node_roles.node_role_arn

  depends_on = [module.eks]
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_region" "current" {}
