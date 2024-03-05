resource "aws_cloudwatch_metric_alarm" "example" {
  for_each = var.alarm_metrics

  alarm_name                = "${each.key}-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = each.value.evaluation_periods
  metric_name               = each.value.metric_name
  namespace                 = each.value.namespace
  period                    = each.value.period
  statistic                 = each.value.statistic
  threshold                 = each.value.threshold
  //alarm_actions             = [aws_sns_topic.example.arn]
  alarm_actions             = [var.sns_topic_arn]
  // other configurations...
}

