output "eventbridge_scheduler_arn" {
  value = var.create_eventbridge_scheduler && length(aws_scheduler_schedule.schedule) > 0 ? aws_scheduler_schedule.schedule[0].arn : ""
}

output "lambda_function_arn" {
  value = var.create_lambda_resources && length(aws_lambda_function.vpcflow_logs_lambda) > 0 ? aws_lambda_function.vpcflow_logs_lambda[0].arn : ""
}
