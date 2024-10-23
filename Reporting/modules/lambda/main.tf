resource "null_resource" "create_lambda_zip" {
  for_each = var.lambda_functions

  provisioner "local-exec" {
    command = <<EOT
      echo "Creating ZIP file for ${each.key}..."
      echo "Current working directory: $(pwd)"
      echo "Listing contents of working directory:"
      ls -la

      # Navigate to the Lambda's subdirectory and install dependencies if required
      if [ ${each.value.run_yarn} = true ]; then
        echo "Running yarn install for ${each.key}..."
        yarn install
        if [ \$? -ne 0 ]; then
          echo "Error during yarn install for ${each.key}"
          exit 1
        fi
      fi

      # Compile TypeScript if required
      if [ ${each.value.compile_typescript} = true ]; then
        echo "Compiling TypeScript for ${each.key}..."
        yarn tsc
        if [ \$? -ne 0 ]; then
          echo "Error during TypeScript compilation for ${each.key}"
          exit 1
        fi
      fi

      # Create the ZIP file for the specific Lambda's subdirectory
      echo "Zipping files for ${each.key}..."
      zip -r ${each.key}.zip ./*
      if [ \$? -ne 0 ]; then
        echo "Error creating ZIP file for ${each.key}"
        exit 1
      fi
      echo "ZIP file for ${each.key} created successfully"
    EOT
    working_dir = "${path.module}/../../reporting/${each.value.source_dir}"
  }
}

resource "aws_lambda_function" "lambda" {
  for_each = var.lambda_functions

  function_name = each.key
  handler       = each.value.handler
  runtime       = each.value.runtime
  role          = each.value.role_arn
  timeout       = 899
  filename      = each.value.bucket == "" ? "${path.module}/../../reporting/${each.value.source_dir}/${each.key}.zip" : null
  s3_bucket     = each.value.bucket != "" ? each.value.bucket : null
  s3_key        = each.value.bucket != "" ? "${each.key}.zip" : null

  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }
  environment {
    variables = each.value.environment_variables
  }

  depends_on = [null_resource.create_lambda_zip]
}

resource "aws_s3_bucket_object" "lambda_zip" {
  for_each = { for k, v in var.lambda_functions : k => v if v.bucket != "" }

  bucket = each.value.bucket
  key    = "${each.key}.zip"
  source = "${path.module}/../../reporting/${each.value.source_dir}/${each.key}.zip"

  depends_on = [null_resource.create_lambda_zip]
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  for_each = { for k, v in var.lambda_functions : k => v if v.enable_eventbridge }

  name                = each.value.eventbridge_rule_name
  schedule_expression = each.value.eventbridge_schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  for_each = { for k, v in var.lambda_functions : k => v if v.enable_eventbridge }

  rule      = aws_cloudwatch_event_rule.event_rule[each.key].name
  target_id = each.key
  arn       = aws_lambda_function.lambda[each.key].arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  for_each = { for k, v in var.lambda_functions : k => v if v.enable_eventbridge }

  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule[each.key].arn
}
