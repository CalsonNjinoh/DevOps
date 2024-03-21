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

####### HTTP 5XX Server Errors #######

resource "aws_cloudwatch_metric_alarm" "http_5xx_errors" {
  alarm_name                = "${aws_lb.glaretram_alb.name}-http-5xx-errors"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 5
  metric_name               = "HTTPCode_ELB_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "This alarm monitors HTTP 5XX errors from an ALB, indicating backend failures impacting user experience. Unlike metrics that vary with traffic, a rise in 5XX errors signals critical application or infrastructure issues, such as bugs or resource shortages. Close monitoring allows for swift issue resolution, preserving user accessibility and satisfaction. Adjust the threshold and evaluation period to balance alert sensitivity and prevent false alarms. With detailed monitoring, achieve finer data granularity for quicker diagnostics. Effective management of 5XX errors is key to application health, as outlined in AWS documentation on https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-troubleshooting.html.."
  actions_enabled           = true
  alarm_actions             = [var.alarm_action_arn]

  dimensions = {
    LoadBalancer = aws_lb.glaretram_alb.arn
  }
}

### HTTPCode_Target_5XX_Count ####

resource "aws_cloudwatch_metric_alarm" "target_5xx_errors" {
  alarm_name                = "${aws_lb.glaretram_alb.name}-target-5xx-errors"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 5
  metric_name               = "HTTPCode_Target_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "This alarm tracks HTTP 5XX errors from ALB target groups, pinpointing backend service request processing failures. Unlike fluctuating metrics like CPU or network usage, elevated 5XX errors typically indicate serious app issues or backend server constraints. Monitoring these errors enables quick identification and resolution of issues, safeguarding application reliability and availability. Setting appropriate alarm thresholds and periods, especially with detailed monitoring, enhances prompt issue detection and response. Managing 5XX errors effectively is crucial for service quality, as highlighted in AWS's https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-monitoring.html, ensuring smooth user experiences.."
  actions_enabled           = true
  alarm_actions             = [var.alarm_action_arn]

  dimensions = {
    LoadBalancer = aws_lb.glaretram_alb.arn
  }
}

####### TargetResponseTime ######

resource "aws_cloudwatch_metric_alarm" "target_response_time" {
  alarm_name                = "${aws_lb.glaretram_alb.name}-target-response-time"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 5
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/ApplicationELB"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 1  # Trigger if the average response time exceeds 1 second
  alarm_description         = "This alarm monitors ALB Target Response Time, tracking backend response delays. Unlike fluctuating throughput/load metrics, extended response times often reveal application or backend inefficiencies like slow database queries or code issues. Setting this alarm aids in early bottleneck detection, enabling swift optimizations to enhance responsiveness and user satisfaction. Adjusting the threshold for expected behavior and peak loads achieves optimal alert balance. In detailed monitoring setups, shorter evaluation periods increase alarm responsiveness, aiding faster issue resolution. Efficiently managing response times is vital for optimal application performance, further detailed in AWS's guides on https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html and https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-monitoring.html"
  actions_enabled           = true
  alarm_actions             = [var.alarm_action_arn]

  dimensions = {
    LoadBalancer = aws_lb.glaretram_alb.arn
  }
}

#### UnhealthyHostCount#####

resource "aws_cloudwatch_metric_alarm" "unhealthy_host_count" {
  alarm_name                = "${aws_lb.glaretram_alb.name}-unhealthy-hosts"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 5
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = 300
  statistic                 = "Maximum"
  threshold                 = 2  # Trigger if there is at least 1 unhealthy host
  alarm_description         = "This alarm monitors the UnHealthyHostCount metric for ALB target groups, alerting when unhealthy hosts surpass a set threshold. Unlike traffic metrics, more unhealthy hosts can impair request distribution, risking slower responses or outages. These hosts often fail health checks due to app errors, misconfigurations, or connectivity issues. An alarm for unhealthy host counts facilitates swift issue identification and fixing, maintaining effective traffic routing. Choose alarm thresholds wisely, considering system redundancy and fault tolerance. In detailed monitoring setups, shorter evaluation periods enhance issue detection and resolution speed. Maintaining target health is crucial for service continuity, as outlined in AWS's https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html, promoting application reliability and availability."
  actions_enabled           = true
  alarm_actions             = [var.alarm_action_arn]

  dimensions = {
    LoadBalancer = aws_lb.glaretram_alb.arn
    TargetGroup  = aws_lb_target_group.glaretram_target_group.arn
  }
}
