
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


module "my_asg" {
  source                        = "../../Modules/Auto_scaling"
  create_alb_security_group     = true
  asg_name                      = "APIserver"
  min_size                      = 1
  max_size                      = 3
  desired_capacity              = 1
  vpc_id                        = module.network.vpc_id
  subnet_ids                    = module.network.public_subnet_ids
  launch_template_name          = "api-launch-template"
  launch_template_description   = "Launch template for api ASG"
  image_id                      = "ami-0ea18256de20ecdfc"
  instance_type                 = "t2.micro"
  iam_role_name                 = "amazonssm-managedinstance-iam-role"
  iam_role_description          = "IAM role for AmazonSSMManagedInstanceCore ASG"
  security_group_id             = module.security_group.security_group_id
  availability_zone             = "ca-central-1b"
  alb_subnets                   = [module.network.public_subnet_ids[0], module.network.public_subnet_ids[1]]
  alb_security_groups           = [module.my_asg.alb_security_group_id]
  ssl_certificate_arn           = "arn:aws:acm:us-east-2:891377304437:certificate/ddbed20f-ba7e-48d6-a6cb-f1636883543c"
}

resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "CPUUtilizationTarget"
  autoscaling_group_name = "APIserver-2024030309143282090000000b"
  policy_type            = "TargetTrackingScaling"
  
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}

