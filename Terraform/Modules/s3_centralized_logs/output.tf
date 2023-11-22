
output "bucket_name" {
  description = "Name of the centralized S3 bucket for VPC flow logs"
  value       = aws_s3_bucket.centralized_vpc_flow_logs.bucket
}
output "centralized_vpc_flow_logs_bucket_arn" {
  description = "ARN of the centralized S3 bucket for VPC flow logs"
  value       = aws_s3_bucket.centralized_vpc_flow_logs.arn
}
