#event-bridge 
#main.tf

############################################
# Create EventBridge Scheduler
############################################
resource "aws_scheduler_schedule" "schedule" {
  name                = var.schedule_name
  description         = var.schedule_description
  schedule_expression = var.schedule_pattern  # Define a rate or cron expression

  target {
    arn      = var.lambda_function_arn  # This should reference the Lambda ARN dynamically
    role_arn = aws_iam_role.lambda_execution_role.arn  # Use the role we create below
  }

  flexible_time_window {
    mode = "OFF"
  }
}

############################################
# IAM Role for EventBridge Scheduler to invoke Lambda
############################################
resource "aws_iam_role" "lambda_execution_role" {
  name = "scheduler_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "scheduler.amazonaws.com"  # Allow EventBridge Scheduler to assume this role
        }
      }
    ]
  })
}

############################################
# IAM Policy for Invoking Lambda
############################################
resource "aws_iam_role_policy" "lambda_invoke_policy" {
  name   = "lambda_invoke_policy"
  role   = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = [
          "${var.lambda_function_arn}:*",  # Use the lambda function ARN dynamically
          var.lambda_function_arn  # The base ARN without versioning
        ]
      }
    ]
  })
}

############################################
# Lambda Permission to allow EventBridge Scheduler to invoke Lambda
############################################
resource "aws_lambda_permission" "allow_scheduler_invoke_lambda" {
  statement_id  = "AllowExecutionFromScheduler"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn  # Dynamically use Lambda ARN here
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.schedule.arn  # Fixed reference to aws_scheduler_schedule
}


#output.tf

output "eventbridge_scheduler_arn" {
  value = aws_scheduler_schedule.schedule.arn  # Fixed reference to aws_scheduler_schedule
}


#variables.tf

variable "schedule_name" {
  description = "Name of the EventBridge schedule"
  default     = "my-lambda-scheduler"
}

variable "schedule_description" {
  description = "Description of the EventBridge schedule"
  default     = "A scheduled rule to run every 5 minutes"
}

variable "schedule_pattern" {
  description = "The schedule expression (rate or cron)"
  default     = "rate(5 minutes)"  # You can use a cron expression if needed
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to invoke"
}



Lambda 

############################################
# Create IAM Role for Lambda
############################################
resource "aws_iam_role" "lambda_role" {
  name = "VPCFlowLogs_Lambda_Role"
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
  name        = "VPCFlowLogs_Lambda_Policy"
  description = "Policy for Lambda to write logs to CloudWatch"
  path        = "/"
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
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

############################################
# Create Lambda Function
############################################
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/python"  # Directory where your Lambda code is located
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "vpcflow_logs_lambda" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = var.handler
  runtime          = var.runtime
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60
  memory_size      = 128

  environment {
    variables = var.environment_variables
  }
}



#output.tf

output "lambda_function_arn" {
  value = aws_lambda_function.vpcflow_logs_lambda.arn
  description = "The ARN of the Lambda function"
}



#variables.tf 

variable "function_name" {
  type = string
  description = "Name of the Lambda function"
}

variable "handler" {
  type = string
  description = "The Lambda function handler (e.g., index.handler)"
}

variable "runtime" {
  type = string
  description = "The runtime environment for the Lambda function (e.g., python3.8)"
}

variable "environment_variables" {
  type = map(string)
  description = "Environment variables for the Lambda function"
  default = {}
}


