output "sns_topic_arn" {
  value = aws_sns_topic.slack_notify_topic.arn
}
