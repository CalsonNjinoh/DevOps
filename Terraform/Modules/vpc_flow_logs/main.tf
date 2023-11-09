resource "aws_flow_log" "vpc_flow_log" {
  log_destination      = var.bucket_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
  iam_role_arn         = var.iam_role_arn
}
variable "vpc_id" {
  description = "The VPC ID for which to enable flow logs."
  type        = string
}
variable "bucket_arn" {
  description = "The ARN of the S3 bucket where logs will be stored."
  type        = string
}
variable "iam_role_arn" {
  description = "The ARN of the IAM role for publishing logs to S3."
  type        = string
}
