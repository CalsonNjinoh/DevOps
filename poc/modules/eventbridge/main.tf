##############################
# GuardDuty 
##############################

# data "aws_guardduty_detector" "existing" {}
# resource "aws_guardduty_detector" "main" {
#   count = length(data.aws_guardduty_detector.existing.id) == 0 ? 1 : 0
# }

# resource "aws_guardduty_detector" "main" {
#   count  = var.enable_guardduty ? 1 : 0
#   enable = var.enable_guardduty
# }
resource "aws_cloudwatch_event_rule" "guardduty_rule" {
  count       = var.enable_guardduty ? 1 : 0
  name        = "guardduty-event-rule-${var.environment}"
  description = "Event rule for GuardDuty findings"
  event_pattern = jsonencode({
    "source" : [
      "aws.guardduty"
    ],
    "detail-type" : [
      "GuardDuty Finding"
    ]
  })
}
resource "aws_cloudwatch_event_target" "guardduty_target" {
  count     = var.enable_guardduty ? 1 : 0
  rule      = aws_cloudwatch_event_rule.guardduty_rule[0].name
  target_id = "send-to-sns-${var.environment}"
  arn       = var.sns_topic_arn
}


############################################
# Create EventBridge Scheduler
############################################

resource "aws_scheduler_schedule" "schedule" {
  count               = var.create_eventbridge_scheduler ? 1 : 0
  name                = var.schedule_name
  description         = var.schedule_description
  schedule_expression = var.schedule_pattern  

  target {
    arn      = var.lambda_function_arn  
    role_arn = aws_iam_role.lambda_execution_role[count.index].arn  
  }

  flexible_time_window {
    mode = "OFF"
  }
}

####################################################
# IAM Role for EventBridge Scheduler to invoke Lambda
#####################################################

resource "aws_iam_role" "lambda_execution_role" {
  count = var.create_eventbridge_scheduler ? 1 : 0
  name  = "scheduler_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "scheduler.amazonaws.com"  
        }
      }
    ]
  })
}

############################################
# IAM Policy for Invoking Lambda
############################################

resource "aws_iam_role_policy" "lambda_invoke_policy" {
  count = var.create_eventbridge_scheduler ? 1 : 0
  name  = "lambda_invoke_policy"
  role  = aws_iam_role.lambda_execution_role[count.index].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = [
          "${var.lambda_function_arn}:*", 
          var.lambda_function_arn 
        ]
      }
    ]
  })
}

###################################################################
# Lambda Permission to allow EventBridge Scheduler to invoke Lambda
####################################################################

resource "aws_lambda_permission" "allow_scheduler_invoke_lambda" {
  count        = var.create_eventbridge_scheduler ? 1 : 0
  statement_id = "AllowExecutionFromScheduler"
  action       = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn  
  principal    = "scheduler.amazonaws.com"
  source_arn   = aws_scheduler_schedule.schedule[count.index].arn 
}

############################################
# Create IAM Role for Lambda
############################################

resource "aws_iam_role" "lambda_role" {
  count = var.create_lambda_resources ? 1 : 0
  name  = "VPCFlowLogs_Lambda_Role"
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

############################################
# Attach IAM Policy to Lambda Role
############################################

resource "aws_iam_policy" "lambda_policy" {
  count      = var.create_lambda_resources ? 1 : 0
  name       = "VPCFlowLogs_Lambda_Policy"
  description = "Policy for Lambda to write logs to CloudWatch"
  path       = "/"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  count     = var.create_lambda_resources ? 1 : 0
  policy_arn = aws_iam_policy.lambda_policy[count.index].arn
  role       = aws_iam_role.lambda_role[count.index].name
}

############################################
# Create Lambda Function for VPC Flow Logs
############################################

data "archive_file" "lambda_zip" {
  count      = var.create_lambda_resources ? 1 : 0
  type       = "zip"
  source_dir = "${path.module}/python"  
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "vpcflow_logs_lambda" {
  count            = var.create_lambda_resources ? 1 : 0
  function_name    = var.function_name
  role             = aws_iam_role.lambda_role[count.index].arn
  handler          = var.handler
  runtime          = var.runtime
  filename         = data.archive_file.lambda_zip[count.index].output_path
  source_code_hash = data.archive_file.lambda_zip[count.index].output_base64sha256
  timeout          = 60
  memory_size      = 128

  environment {
    variables = var.environment_variables
  }
}
