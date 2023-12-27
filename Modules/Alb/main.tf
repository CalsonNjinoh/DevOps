########################################
# Dev Glaretram_mqtt ALB 
########################################


resource "aws_lb" "glaretram_alb" {
  name               = "dev-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group]
  enable_deletion_protection = false
  subnets            = var.subnets
}

########################################
# Glaretram http & https Listeners
########################################

resource "aws_lb_listener" "glaretram_listener" {
  load_balancer_arn = aws_lb.glaretram_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.glaretram_target_group.arn
  }
}
resource "aws_lb_listener" "glaretram_http_listener" {
  load_balancer_arn = aws_lb.glaretram_alb.arn
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
# Glaretram Target Group and Attachment
########################################

resource "aws_lb_target_group" "glaretram_target_group" {
  name     = "glaretram-target-group"
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
resource "aws_lb_target_group_attachment" "glaretram_tg_attachment" {
  target_group_arn = aws_lb_target_group.glaretram_target_group.arn
  target_id        = var.glaretram_ec2_instance_id
  port             = 80
}
