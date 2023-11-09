provider "aws" {
  region = var.region
}
  module "iam_roles" {
  source          = "../../modules/iam_roles"
  create_ssm_role = true
  # Set other role variables to true or false as needed
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
  centralized_vpc_flow_logs_bucket_arn = "arn:aws:s3:::dev-centralized-vpc-flow-logs-bucket"
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
    }
  ]
}


########################################
# Create Application Load Balancer 
########################################

module "Alb" {
  source              = "../../modules/alb"
  vpc_id              = module.network.vpc_id
  subnets             = module.network.public_subnet_ids
  glaretram_ec2_instance_id = module.glaretram.instance_id
  alb_security_group = module.glaretram_alb_sg.security_group_id
  acm_certificate_arn = "arn:aws:acm:ca-central-1:762372983622:certificate/446d6102-541f-4f4b-a73c-efb4214c7eab"
  alb_dns_name = "api.aetonix.xyz"
}

########################################
# Create Security Group for ALB
########################################

module "glaretram_alb_sg" {
  source              = "../../modules/security_group"
  name                = "glaretram-alb-sg"
  description         = "Security group for Glaretram ALB"
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
# Create EC2 using Custom EC2 AMI
########################################

module "vasco_redis" {
  source         = "../../modules/ec2_instance"
  ami_id         = "ami-043032a742bfa29e1"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "vasco-redis"
  key_name       = module.ssh_key_pair.key_name
  iam_instance_profile_name = module.iam_roles.ssm_instance_profile_name
  }

module "tupacase" {
  source         = "../../modules/ec2_instance"
  ami_id         = "ami-0a29cf3c1c0332bc5"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "tupacase"
  key_name       = module.ssh_key_pair.key_name
  iam_instance_profile_name = module.iam_roles.ssm_instance_profile_name
}

module "green_posgress-logs" {
  source         = "../../modules/ec2_instance"
  ami_id         = "ami-03b357933ddaf7302"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "green-postgress-logs"
  key_name       = module.ssh_key_pair.key_name
  iam_instance_profile_name = module.iam_roles.ssm_instance_profile_name
}
module "Glaretram_MQTT" {
  source         = "../../modules/ec2_instance"
  ami_id         = "ami-080cd100f83d90e33"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "glaretram_mqtt"
  key_name       = module.ssh_key_pair.key_name
  iam_instance_profile_name = module.iam_roles.ssm_instance_profile_name
}
module "glaretram" {
  source         = "../../modules/ec2_instance"
  ami_id         = "ami-0130e987f0ee042c7"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "glaretram"
  key_name       = module.ssh_key_pair.key_name
  iam_instance_profile_name = module.iam_roles.ssm_instance_profile_name
}
module "bobones_mongo-replica" {
  source         = "../../modules/ec2_instance"
  ami_id         = "ami-0130e987f0ee042c7"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "bobones_mongo_replica"
  key_name       = module.ssh_key_pair.key_name
  iam_instance_profile_name = module.iam_roles.ssm_instance_profile_name
}
module "mongo_arbiter" {
  source         = "../../modules/ec2_instance"
  ami_id         = "ami-0130e987f0ee042c7"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "mongo_arbiter"
  key_name       = module.ssh_key_pair.key_name
  iam_instance_profile_name = module.iam_roles.ssm_instance_profile_name
}
module "valize_mongo_replica" {
  source         = "../../modules/ec2_instance"
  ami_id         = "ami-0130e987f0ee042c7"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "valize_mongo_replica"
  key_name       = module.ssh_key_pair.key_name
  iam_instance_profile_name = module.iam_roles.ssm_instance_profile_name
}

module "iam_role_for_logs" {
  source = "../../modules/iam_role_for_logs"
  bucket_name = "dev-centralized-vpc-flow-logs-bucket"
}


###############################################################
# Cloudfront Distribution Creation for Dashboard and Mobile App
###############################################################

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for mobile_app identity for cloudfront to access s3 bucket"
}
module "cloudfront" {
  source                   = "../../modules/cloudfront"
  domain_name              = data.aws_s3_bucket.mobile_app_existing_bucket.bucket_domain_name
  origin_access_identity   = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
  price_class              = "PriceClass_200" # North America and Europe
  security_policy          = "TLSv1.2_2021"
  http_versions            = "http2"
  acm_certificate_arn      = "arn:aws:acm:us-east-1:762372983622:certificate/aa28f9ce-ddfe-4c6f-a0b4-0b5146956494"
  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2021"
  aliases                  = ["appdev.aetonix.xyz"]
}
output "cloudfront_domain" {
  value = "module.my_cloudfront.cloudfront_domain"
}

# reference to existing s3 bucket as cloudfront origin for mobile_app

data "aws_s3_bucket" "mobile_app_existing_bucket" {
  bucket = "ae-dev-mobile-appa12ef22222"
}
resource "aws_cloudfront_origin_access_identity" "dashboard_oai" {
  comment = "OAI for Dashboard cloudfront to access s3 bucket"
}
module "dashboard_cloudfront" {
  source                   = "../../modules/cloudfront"
  domain_name              = data.aws_s3_bucket.dashboard_existing_bucket.bucket_domain_name
  origin_access_identity   = aws_cloudfront_origin_access_identity.dashboard_oai.cloudfront_access_identity_path
  price_class              = "PriceClass_200" # North America and Europe
  security_policy          = "TLSv1.2_2021"
  http_versions            = "http2"
  acm_certificate_arn      = "arn:aws:acm:us-east-1:762372983622:certificate/aa28f9ce-ddfe-4c6f-a0b4-0b5146956494"
  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2021"
  aliases                  = ["devdashboard.aetonix.xyz"]
}
output "dashboard_cloudfront_domain" {
  value = "module.dashboard_cloudfront.cloudfront_domain"
}
data "aws_s3_bucket" "dashboard_existing_bucket" {
  bucket = "ae-dev-dashboard-1423efee"  
}


########################################
# Opensearch Domain Creation
########################################


module "opensearch" {
  source = "../../modules/opensearch"
  domain_name           = "devtest"
  elasticsearch_version = "OpenSearch_2.9"
  instance_type         = "t3.medium.elasticsearch"
  instance_count        = 2
  ebs_enabled           = true
  volume_size           = 20
  volume_type           = "gp2" 
  security_group_ids    = [module.security_group.security_group_id]
  private_subnet_ids    = module.network.private_subnet_ids[0]
  }

