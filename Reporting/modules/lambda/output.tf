output "lambda_function_arn" {
  value = { for k, v in aws_lambda_function.lambda : k => v.arn }
}

output "lambda_function_name" {
  value = { for k, v in aws_lambda_function.lambda : k => v.function_name }
}
