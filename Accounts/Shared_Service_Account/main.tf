//provider "aws" {
  //region = var.region
  //assume_role {
    //role_arn = "arn:aws:iam::427366260079:role/CrossAccountRoute53Access"  # IAM role created in the management account
  //}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  }


#Original Shared_Service Module 

module "route53" {
  source              = "../../modules/route53"
  public_domain_name  = var.public_domain_name
  #private_domain_name = var.private_domain_name
  vpc_id              = var.vpc_id
  public_records      = merge(var.public_records, {
    "jenkins.aetonix.xyz" = {
      type    = "CNAME"
      ttl     = "300"
      records = [module.jenkins_alb.alb_dns_name]
    }
  })

  #private_records     = var.private_records
}
module "acm_certificate" {
  source          = "../../modules/Acm_certificates"
  region = var.region
  domain_name     = "*.aetonix.xyz"
  tags        = {
    Environment = "Shared_Service"
  }
}

# Jenkins Configurations 


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
  centralized_vpc_flow_logs_bucket_arn = "arn:aws:s3:::dev-centralized-vpc-flow-logs-bucket"
}

########################################
# Create Application Load Balancer 
########################################

module "jenkins_alb" {
  source              = "../../modules/jenkins_alb"
  vpc_id              = module.network.vpc_id
  subnets             = module.network.public_subnet_ids
  jenkins_ec2_instance_id = module.jenkins.instance_id
  openldap_ec2_instance_id = module.openldap.instance_id
  alb_security_group = module.jenkins_alb_sg.security_group_id
  acm_certificate_arn = "arn:aws:acm:ca-central-1:338674575706:certificate/d2f8e913-04a2-4c9e-a547-eaeacbdb39e2"
  alb_dns_name = "jenkins.aetonix.xyz"
}

########################################
# Create Security Group for ALB
########################################

module "jenkins_alb_sg" {
  source              = "../../modules/security_group"
  name                = "jenkins-alb-sg"
  description         = "Security group for Jenkins ALB"
  vpc_id              = module.network.vpc_id

  ingress_rules = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
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
# Create Security Group for EC2s
########################################

module "security_group" {
  source = "../../modules/security_group"
  name   = "jenkins-sg"
  description = "Security group for Jenkins"
  vpc_id = module.network.vpc_id
  ingress_rules = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      },
    {
      description = "HTTPS"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

########################################
# Custom EC2 Jenkins & Ldap 
########################################

module "jenkins" {
  source         = "../../modules/ec2_instance"
  ami_id         = "ami-0ce27c0c9c31a6693"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "jenkins"
  key_name       = module.ssh_key_pair.key_name
  vpc_security_group_ids = [module.security_group.security_group_id]
}
module "openldap" {
  source         = "../../modules/ec2_instance"
  ami_id         = "ami-02c9a0b2bca4a8395"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "openldap"
  key_name       = module.ssh_key_pair.key_name
  vpc_security_group_ids = [module.security_group.security_group_id]
}
module "iam_role_for_logs" {
  source = "../../modules/iam_role_for_logs"
  bucket_name = "dev-centralized-vpc-flow-logs-bucket"
}
