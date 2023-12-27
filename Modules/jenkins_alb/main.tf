########################################
# Jenkins and Ldap Load Balancer
########################################


resource "aws_lb" "jenkins_alb" {
  name               = "jenkins-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group]
  enable_deletion_protection = false
  subnets            = var.subnets
}

########################################
# Jenkins http & https Listeners
########################################

resource "aws_lb_listener" "jenkins_listener" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_target_group.arn
  }
}
resource "aws_lb_listener" "jenkins_http_listener" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

########################################
# Jenkins Target Group and Attachment
########################################

resource "aws_lb_target_group" "jenkins_target_group" {
  name     = "jenkins-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled             = true
    path                = "/"
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
    port                = "80"
  }
}
resource "aws_lb_target_group_attachment" "jenkins_tg_attachment" {
  target_group_arn = aws_lb_target_group.jenkins_target_group.arn
  target_id        = var.jenkins_ec2_instance_id
  port             = 8080
}

########################################
# Target Group for openLDAP
########################################

resource "random_pet" "openldap_name" {
  length    = 1  # Producing a shorter name this will help if we need to change listner rule priority
  separator = "-"
} 

resource "aws_lb_target_group" "openldap_target_group" {
  name     = "ldap-tg-${random_pet.openldap_name.id}" 
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled             = true
    path                = "/"
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
    port                = "80"
  }
}
resource "aws_lb_target_group_attachment" "openldap_tg_attachment" {
  target_group_arn = aws_lb_target_group.openldap_target_group.arn
  target_id        = var.openldap_ec2_instance_id
  port             = 80
}

#################################################
# listener Rule for jenkins pathbase routing
#################################################

resource "aws_lb_listener_rule" "jenkins_rule" {
  listener_arn = aws_lb_listener.jenkins_listener.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_target_group.arn
  }
  condition {
    host_header {
      values = ["jenkins.aetonix.xyz"]
    }
  }
}

#################################################
# listener Rule for openldap pathbase routing
#################################################

resource "aws_lb_listener_rule" "openldap_rule" {
  listener_arn = aws_lb_listener.jenkins_listener.arn
  priority     = 101
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.openldap_target_group.arn
  }
  condition {
    host_header {
      values = ["ldap.aetonix.xyz"]
    }
  }
  lifecycle {
    create_before_destroy = true # ensure that the new rule is created before the old one is deleted
  }
}
