############################################
# Create Lambda Role
############################################
resource "aws_iam_role" "lambda_role" {
  name = "SNS_Slack_Lambda_Role_${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ]
  })
}

resource "aws_iam_policy" "iam_policy" {
  name        = "SNS_Slack_Lambda_Policy_${var.env}"
  description = "Policy for SNS Slack Lambda"
  path        = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  policy_arn = aws_iam_policy.iam_policy.arn
  role       = aws_iam_role.lambda_role.name
}

############################################
# Create Lambda Function
############################################

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/python"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "slack_notify_lambda" {
  function_name    = "SNS_Slack_Lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60
  memory_size      = 128
}

############################################
# Create SNS Topic
############################################

resource "aws_sns_topic" "slack_notify_topic" {
  name = "SNS_Slack_Topic"
}

############################################
# Create SNS Subscription
############################################

resource "aws_sns_topic_subscription" "slack_notify_subscription" {
  topic_arn = aws_sns_topic.slack_notify_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notify_lambda.arn
}
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notify_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.slack_notify_topic.arn
}

resource "aws_cloudwatch_metric_alarm" "sns_lambda_alarm" {
  alarm_name                = "SNS_Slack_Lambda_Alarm"
  alarm_description         = "Alarm for SNS Slack Lambda"
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.slack_notify_topic.arn]
  insufficient_data_actions = [aws_sns_topic.slack_notify_topic.arn]
  ok_actions                = [aws_sns_topic.slack_notify_topic.arn]
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  statistic                 = "Sum"
  period                    = 60
  evaluation_periods        = 1
  threshold                 = 1
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.slack_notify_lambda.function_name
  }
}
