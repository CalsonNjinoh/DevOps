provider "aws" {
  region = var.region
}

########################################
# Route 53 Zone Lookup
########################################
data "aws_route53_zone" "aetonixxyz" {
  name = "aetonix.xyz"
}

########################################
# Default Ubuntu EC2 AMI
########################################

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*ubuntu*"]
  }
}

########################################
# Create VPC, Subnets, Route Tables
########################################

module "network" {
  source = "../../modules/vpc"
  name   = var.name

  azs  = var.azs
  cidr = var.cidr

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags
}


########################################
# Create SSH Key Pair for EC2s
########################################

module "ssh_key_pair" {
  source   = "../../modules/ssh_key_pair"
  key_path = var.key_path
  name     = var.name
}

########################################
# Create required AMIs
########################################
module "iam" {
  source = "../../modules/iam"
  tags   = var.tags
  name   = var.name
}

########################################
# Create VPN EC2
########################################
module "openvpn" {
  source                = "../../modules/openvpn"
  subnet                = module.network.public_subnet_ids[0]
  ssh_key_name          = module.ssh_key_pair.key_name
  vpc_cidr              = var.cidr
  vpc_id                = module.network.vpc_id
  tags                  = var.tags
  instance_profile      = module.iam.ec2_iam_role
  route_53_zone_id      = data.aws_route53_zone.aetonixxyz.zone_id
  domain_name           = "vpn.staging.aetonix.xyz"
  openvpn_ingress_ports = [80, 443, 1194, 943]
  ssh_ingress_ports     = [22]
  egress_ports          = [0]
}

########################################
# Create Mongo Instances
########################################

module "mongo" {
  source                = "../../modules/mongo"
  subnets               = module.network.private_subnet_ids
  instance_ami          = data.aws_ami.ubuntu.id
  replica_instance_type = "t3.medium"
  arbiter_instance_type = "t3.micro"
  ssh_key_name          = module.ssh_key_pair.key_name
  vpc_cidr              = var.cidr
  num_of_replicas       = 2
  secure_ssh_sg         = module.openvpn.ssh_sg.id
  vpc_id                = module.network.vpc_id
  tags                  = var.tags
  instance_profile      = module.iam.ec2_iam_role
  root_volume_size      = 20
  volume_type           = "gp2"
  mongo_ebs_block_device      = [
    {
      # Data
      device_name           = "/dev/xvdba"
      volume_size           = 50
      volume_type           = "io1"
      iops                  = "1000"
      delete_on_termination = true
    },
    {
      # Journal
      device_name           = "/dev/xvdbb"
      volume_size           = 30
      volume_type           = "io1"
      iops                  = "250"
      delete_on_termination = true
    },
    {
      # Log
      device_name           = "/dev/xvdbc"
      volume_size           = 31
      volume_type           = "io1"
      iops                  = "100"
      delete_on_termination = true
    }
  ]
  arbiter_ebs_block_device = [
    {
      # Data
      device_name           = "/dev/xvdba"
      volume_size           = 20
      volume_type           = "gp2"
      delete_on_termination = true
    }
  ]
  ingress_ports    = [7616]
  egress_ports     = [0]
}

########################################
# Create Redis Instance
########################################

module "redis" {
  source           = "../../modules/redis"
  subnet           = module.network.private_subnet_ids[0]
  instance_ami     = data.aws_ami.ubuntu.id
  instance_type    = "t3.micro"
  ssh_key_name     = module.ssh_key_pair.key_name
  vpc_cidr         = var.cidr
  secure_ssh_sg    = module.openvpn.ssh_sg.id
  vpc_id           = module.network.vpc_id
  tags             = var.tags
  instance_profile = module.iam.ec2_iam_role
  root_volume_size = 20
  volume_type      = "gp2"
  ebs_block_device = [
    {
      # Data
      device_name           = "/dev/xvdba"
      volume_size           = 40
      volume_type           = "gp2"
      delete_on_termination = true
    }
  ]
  ingress_ports    = [6169, 6168]
  egress_ports     = [0]
}

########################################
# Create Elephant Instance
########################################

module "elephants" {
  source            = "../../modules/elephants"
  subnets           = module.network.private_subnet_ids
  instance_ami      = data.aws_ami.ubuntu.id
  instance_type     = "t3.micro"
  num_of_elephants  = 2
  ssh_key_name      = module.ssh_key_pair.key_name
  vpc_cidr          = var.cidr
  secure_ssh_sg     = module.openvpn.ssh_sg.id
  vpc_id            = module.network.vpc_id
  tags              = var.tags
  instance_profile  = module.iam.ec2_iam_role
  ingress_ports     = [43616]
  egress_ports      = [0]
  root_volume_size  = 20
  block_volume_size = 40
  volume_type       = "gp2"
  device_name       = "/dev/xvdba"
}
