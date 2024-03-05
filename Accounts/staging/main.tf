provider "aws" {
  region = var.region
}
  module "iam_roles" {
  source          = "../../modules/iam_roles"
  create_ssm_role = true
  # Set other role variables to true or false as needed
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
# Create Application Load Balancer 
########################################

//module "Alb" {
  //source              = "../../modules/alb"
  //vpc_id              = module.network.vpc_id
  //subnets             = module.network.public_subnet_ids
  //glaretram_ec2_instance_id = module.glaretram.instance_id
  //alb_security_group = module.glaretram_alb_sg.security_group_id
  //acm_certificate_arn = "arn:aws:acm:ca-central-1:762372983622:certificate/446d6102-541f-4f4b-a73c-efb4214c7eab"
  //alb_dns_name = "api.aetonix.xyz"
//}

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
  ami_id         = "ami-05fb0b8c1424f266b"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "vasco-redis"
  key_name       = module.ssh_key_pair.key_name
  iam_instance_profile_name = module.iam_roles.ssm_instance_profile_name
  }

module "tupacase" {
  source         = "../../modules/ec2_instance"
  ami_id         = "ami-05fb0b8c1424f266b"
  instance_type  = "t2.micro"
  subnet_id      = module.network.private_subnet_ids[0]
  instance_name  = "tupacase"
  key_name       = module.ssh_key_pair.key_name
  iam_instance_profile_name = module.iam_roles.ssm_instance_profile_name
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
  centralized_vpc_flow_logs_bucket_arn = "arn:aws:s3:::testbucketnelly"
}

########################################
# Create Security Group 
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
# Create Auto Scaling Group
########################################


module "asg" {
  source                        = "../../Modules/Auto_scaling"
  create_alb_security_group     = true
  asg_name                      = "APIserver"
  min_size                      = 1
  max_size                      = 3
  desired_capacity              = 2
  vpc_id                        = module.network.vpc_id
  subnet_ids                    = module.network.public_subnet_ids
  launch_template_name          = "api-launch-template"
  launch_template_description   = "Launch template for api ASG"
  image_id                      = "ami-05fb0b8c1424f266b"
  instance_type                 = "t2.micro"
  iam_role_name                 = "amazonssm-managedinstance-iam-role"
  iam_role_description          = "IAM role for AmazonSSMManagedInstanceCore ASG"
  security_group_id             = module.security_group.security_group_id
  availability_zone             = "us-east-2b"
  alb_subnets                   = [module.network.public_subnet_ids[0], module.network.public_subnet_ids[1]]
  alb_security_groups           = [module.asg.alb_security_group_id]
  ssl_certificate_arn           = "arn:aws:acm:us-east-2:891377304437:certificate/ddbed20f-ba7e-48d6-a6cb-f1636883543c"
}

resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "CPUUtilizationTarget"
  autoscaling_group_name = module.asg.asg_name
  policy_type            = "TargetTrackingScaling"
  
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}


########################################
# Cloud Watch Alarms 
########################################

# In your root module's main.tf or where the module is called

module "cloudwatch_alarms_staging" {
  source = "../../Modules/Cloudwatch_Alarms"

  alarm_metrics = {
    "cpu_utilization" = {
      metric_name        = "CPUUtilization"
      namespace          = "AWS/EC2"
      statistic          = "Average"
      threshold          = 75
      evaluation_periods = 2
      period             = 300
      // Removed the direct ARN assignment here
    },
    "disk_read_ops" = {
      metric_name        = "DiskReadOps"
      namespace          = "AWS/EC2"
      statistic          = "Average"
      threshold          = 100
      evaluation_periods = 2
      period             = 300
    }
    // Additional metrics if any...
  }
  
  sns_topic_arn = "arn:aws:sns:us-east-2:891377304437:Notification" // Pass the ARN as a module argument
}

# repeat this step for each ec2-instance 

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_vasco_redis" {
  alarm_name                = "cpu-high-vasco-redis"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "75"
  alarm_description         = "This metric monitors EC2 CPU utilization"
  alarm_actions             = ["arn:aws:sns:us-east-2:891377304437:Notification"]
  ok_actions                = ["arn:aws:sns:us-east-2:891377304437:Notification"]
  insufficient_data_actions = ["arn:aws:sns:us-east-2:891377304437:Notification"]

  dimensions = {
    InstanceId = module.vasco_redis.instance_id
  }
}
