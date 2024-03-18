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
locals {
  instances = {
    vasco_redis = {
      ami_id         = "ami-05fb0b8c1424f266b"
      instance_type  = "t2.micro"
      instance_name  = "vasco-redis"
      # Add any other parameters needed for your module
    },
    tupacase = {
      ami_id         = "ami-05fb0b8c1424f266b"
      instance_type  = "t2.micro"
      instance_name  = "tupacase"
      # Add any other parameters needed for your module
    }
  }
}

module "ec2_instances" {
  for_each        = local.instances
  source          = "../../modules/ec2_instance"
  ami_id          = each.value.ami_id
  instance_type   = each.value.instance_type
  subnet_id       = module.network.private_subnet_ids[0]  # Assuming the same subnet for simplicity.
  instance_name   = each.key
  key_name        = module.ssh_key_pair.key_name
  iam_instance_profile_name = module.iam_roles.ssm_instance_profile_name
  # Include any other parameters your module expects.
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
  min_size                      = 0
  max_size                      = 3
  desired_capacity              = 1
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
resource "aws_cloudwatch_metric_alarm" "asg_cpu_utilization_alarm" {
  alarm_name          = "asg-cpu-high-${module.asg.asg_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "This metric monitors ASG CPU utilization"

  dimensions = {
    AutoScalingGroupName = module.asg.asg_name
  }

  alarm_actions             = [module.staging_sns_topic.sns_topic_arn]
  ok_actions                = [module.staging_sns_topic.sns_topic_arn]
  insufficient_data_actions = [module.staging_sns_topic.sns_topic_arn]
}

########################################
# SNS Topic Creation 
########################################

module "staging_sns_topic" {
  source                      = "../../modules/sns_topic"
  sns_topic_name              = "staging-alarm-notifications"
  subscription_email_addresses = ["calson@team4techsolutions.com"]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  for_each                  = module.ec2_instances

  alarm_name                = "cpu-high-${each.key}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "75"
  alarm_description         = "This metric monitors EC2 CPU utilization for ${each.key}"
  alarm_actions             = [module.staging_sns_topic.sns_topic_arn]
  ok_actions                = [module.staging_sns_topic.sns_topic_arn]
  insufficient_data_actions = [module.staging_sns_topic.sns_topic_arn]

  dimensions = {
    InstanceId = each.value.instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_usage_alarm" {
  for_each                  = module.ec2_instances

  alarm_name                = "DiskUsage-${each.key}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "disk_used_percent"
  namespace                 = "CWAgent"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors disk usage for ${each.key}"
  alarm_actions             = [module.staging_sns_topic.sns_topic_arn]
  ok_actions                = [module.staging_sns_topic.sns_topic_arn]
  insufficient_data_actions = [module.staging_sns_topic.sns_topic_arn]

  dimensions = {
    InstanceId = each.value.instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  for_each            = module.ec2_instances

  alarm_name          = "EC2-status-check-failed-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "0" # Trigger the alarm if the status check fails even once
  alarm_description         = "This metric monitors disk usage for ${each.key}"
  alarm_actions             = [module.staging_sns_topic.sns_topic_arn]
  ok_actions                = [module.staging_sns_topic.sns_topic_arn]
  insufficient_data_actions = [module.staging_sns_topic.sns_topic_arn]

  dimensions = {
    InstanceId = each.value.instance_id
  }
}



############################################
# Cloudwatch Alarm Metrics for loadbalancers 
############################################

resource "aws_cloudwatch_metric_alarm" "unhealthy_host_count" {
  alarm_name                = "unhealthy-host-count"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/ELB"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 1
  alarm_description         = "This metric monitors unhealthy hosts"
  actions_enabled           = true
  alarm_actions             = [module.staging_sns_topic.sns_topic_arn]
  ok_actions                = [module.staging_sns_topic.sns_topic_arn]
  insufficient_data_actions = [module.staging_sns_topic.sns_topic_arn]

  dimensions = {
    LoadBalancerName = "APIserver-alb"
  }
}

resource "aws_cloudwatch_metric_alarm" "target_response_time" {
  alarm_name                = "high-response-time"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/ApplicationELB"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 0.5
  alarm_description         = "This metric monitors ALB target response time"
  actions_enabled           = true
  alarm_actions             = [module.staging_sns_topic.sns_topic_arn]
  ok_actions                = [module.staging_sns_topic.sns_topic_arn]
  insufficient_data_actions = [module.staging_sns_topic.sns_topic_arn]

  dimensions = {
    LoadBalancer = "APIserver-alb"
  }
}

resource "aws_cloudwatch_metric_alarm" "http_5xx_errors" {
  alarm_name                = "http-5xx-errors-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "HTTPCode_Target_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 10
  alarm_description         = "Alarm when the count of HTTP 5XX errors exceeds 10 within 5 minutes"
  actions_enabled           = true
  alarm_actions             = [module.staging_sns_topic.sns_topic_arn]
  ok_actions                = [module.staging_sns_topic.sns_topic_arn]
  insufficient_data_actions = [module.staging_sns_topic.sns_topic_arn]

  dimensions = {
    LoadBalancer = "APIserver-alb"
  }
}

resource "aws_cloudwatch_metric_alarm" "http_4xx_errors" {
  alarm_name                = "http-4xx-errors-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "HTTPCode_Target_4XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 100
  alarm_description         = "Alarm when the count of HTTP 4XX errors exceeds 100 within 5 minutes"
  actions_enabled           = true
  alarm_actions             = [module.staging_sns_topic.sns_topic_arn]
  ok_actions                = [module.staging_sns_topic.sns_topic_arn]
  insufficient_data_actions = [module.staging_sns_topic.sns_topic_arn]

  dimensions = {
    LoadBalancer = "APIserver-alb"
  }
}


########################################
# S3 creation For lambda deployment
########################################

resource "aws_s3_bucket" "lambda_deployment_bucket" {
  bucket = "my-lambda-deployment-bucket2" # name should be change used for demo 
  
  tags = {
    Purpose = "Lambda Deployment Packages"
  }
}

resource "aws_s3_bucket_versioning" "lambda_deployment_bucket_versioning" {
  bucket = aws_s3_bucket.lambda_deployment_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


########################################
# Lambda Creation 
########################################

module "lambda_example" {
  //depends_on = [aws_s3_bucket_object.lambda_deployment]
  source            = "../../modules/lambda_function"
  function_name     = "my-staging-lambda-function"
  handler           = "index.handler"
  runtime           = "python3.8"
  s3_bucket         = aws_s3_bucket.lambda_deployment_bucket.bucket
  s3_key            = aws_s3_object.lambda_deployment.key
  source_code_hash  = filebase64sha256("/Users/njinohcalsonchenwi/Aetonix/DevOps/Accounts/staging/lambda_function_payload.zip")
  role_arn          = "arn:aws:iam::891377304437:role/service-role/sns-to-slack-lambda-role-wgoqliwo" # new role needs to be created and reference here 
}

resource "aws_s3_object" "lambda_deployment" {
  bucket       = aws_s3_bucket.lambda_deployment_bucket.bucket
  key          = "lambda_function_payload.zip"
  source       = "/Users/njinohcalsonchenwi/DEVOPS/sns-to-slack/lambda_function_payload.zip"
  etag         = filemd5("/Users/njinohcalsonchenwi/DEVOPS/sns-to-slack/lambda_function_payload.zip")
}

resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowSNSInvoke_${module.lambda_example.lambda_function_name}"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_example.lambda_function_arn
  principal     = "sns.amazonaws.com"
  source_arn    = module.staging_sns_topic.sns_topic_arn
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = module.staging_sns_topic.sns_topic_arn
  protocol  = "lambda"
  endpoint  = module.lambda_example.lambda_function_arn
}

