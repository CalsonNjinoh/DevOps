/*provider "kubernetes" {
  config_path = "~/.kube/config"
}*/

locals {
  tags = var.env[terraform.workspace].tags
}

module "vpc" {
  source                  = "../../modules/vpc/"
  name                    = terraform.workspace
  vpc_id                  = var.vpcs[terraform.workspace]
  vpc_cidr                = var.vpc_cidr
  tags                    = local.tags
  subnet_list             = var.subnet_list
  igw_name                = "${terraform.workspace}-igw-eks"
  public_routetable_name  = "${terraform.workspace}-public-route-table"
  private_routetable_name = "${terraform.workspace}-private-route-table"
  azs                     = var.azs
}


module "eks" {
  depends_on            = [module.vpc]
  vpc_id                = module.vpc.vpc_id
  source                = "../../modules/eks/"
  tags                  = local.tags
  cluster_name          = terraform.workspace
  eks_subnets           = [module.vpc.public_subnet_id[0], module.vpc.public_subnet_id[1], module.vpc.private_subnet_id[0], module.vpc.private_subnet_id[1]]
  subnet_ids            = [module.vpc.private_subnet_id[0], module.vpc.private_subnet_id[1]]
  ec2_ssh_key_name      = var.ec2_ssh_key_name
  instance_types        = [var.instance_type]
  scaling_configuration = var.scaling_configuration
  region                = var.region
  aws_auth_users        = var.aws_auth_users
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "http" "wait_for_cluster" {
  depends_on     = [module.eks]
  url            = format("%s/healthz", data.aws_eks_cluster.eks.endpoint)
  ca_certificate = base64decode(module.eks.kubeconfig-certificate-authority-data)
  timeout        = 1800
}

data "aws_region" "current" {}



