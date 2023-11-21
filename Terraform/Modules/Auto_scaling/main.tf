# Application Load Balancer

resource "aws_lb" "this" {
  name               = "${var.asg_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.alb_subnets
  security_groups    = var.alb_security_groups
}

# Target Group for the Load Balancer

resource "aws_lb_target_group" "this" {
  name     = "${var.asg_name}-tg"
  port     = 21899
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# HTTP Listener

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_listener" "http2" {
  load_balancer_arn = aws_lb.this.arn
  port              = 43433
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# HTTPS Listener

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_security_group" "alb_sg" {
  count = var.create_alb_security_group ? 1 : 0

  name        = "${var.asg_name}-alb-sg"
  description = "Security group for the Application Load Balancer in ${var.asg_name}"
  vpc_id      = var.vpc_id

  # Define your ingress and egress rules

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.asg_name}-alb-sg"
  }
}




module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"

  name                     = var.asg_name
  min_size                 = var.min_size
  max_size                 = var.max_size
  desired_capacity         = var.desired_capacity
  wait_for_capacity_timeout = 0
  health_check_type        = "EC2"
  vpc_zone_identifier      = var.subnet_ids
  target_group_arns = [aws_lb_target_group.this.arn]
  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]

  # Launch template
  launch_template_name        = var.launch_template_name
  launch_template_description = var.launch_template_description
  update_default_version      = true

  image_id          = var.image_id
  instance_type     = var.instance_type
  ebs_optimized     = false
  enable_monitoring = true

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = var.iam_role_name
  iam_role_path               = "/ec2/"
  iam_role_description        = var.iam_role_description
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp2"
      }
    }
  ]

  # Metadata options for improved security
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [var.security_group_id]
    }
  ]

  placement = {
    availability_zone = var.availability_zone
  }

  tags = {
    Environment = "Staging"

  }
}
