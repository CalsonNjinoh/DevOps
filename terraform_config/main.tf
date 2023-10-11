provider "aws" {
  region = var.region
}

########################################
# Create VPC, Subnets, Route Tables
########################################

module "network" {
  source = "./modules/vpc"
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
  source   = "./modules/ssh_key_pair"
  key_path = var.key_path
  name     = var.name
}

########################################
# Custom EC2 AMI
########################################

module "vasco_redis" {
  source         = "./modules/ec2_instance"
  ami_id         = "ami-043032a742bfa29e1"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "vasco-redis"
  key_name       = module.ssh_key_pair.key_name
}

module "tupacase" {
  source         = "./modules/ec2_instance"
  ami_id         = "ami-0a29cf3c1c0332bc5"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "tupacase"
  key_name       = module.ssh_key_pair.key_name
}

module "jenkins_agent" {
  source         = "./modules/ec2_instance"
  ami_id         = "ami-0edb6d54de9acef3a"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "jenkins_agent"
  key_name       = module.ssh_key_pair.key_name
}
module "green_posgress-logs" {
  source         = "./modules/ec2_instance"
  ami_id         = "ami-03b357933ddaf7302"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "green-postgress-logs"
  key_name       = module.ssh_key_pair.key_name
}
module "Glaretram_MQTT" {
  source         = "./modules/ec2_instance"
  ami_id         = "ami-080cd100f83d90e33"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "glaretram_mqtt"
  key_name       = module.ssh_key_pair.key_name
}
module "glaretram" {
  source         = "./modules/ec2_instance"
  ami_id         = "ami-0130e987f0ee042c7"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "glaretram"
  key_name       = module.ssh_key_pair.key_name
}
module "bobones_mongo-replica" {
  source         = "./modules/ec2_instance"
  ami_id         = "ami-0130e987f0ee042c7"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "bobones_mongo_replica"
  key_name       = module.ssh_key_pair.key_name
}
module "mongo_arbiter" {
  source         = "./modules/ec2_instance"
  ami_id         = "ami-0130e987f0ee042c7"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "mongo_arbiter"
  key_name       = module.ssh_key_pair.key_name
}
module "valize_mongo_replica" {
  source         = "./modules/ec2_instance"
  ami_id         = "ami-0130e987f0ee042c7"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "valize_mongo_replica"
  key_name       = module.ssh_key_pair.key_name
}