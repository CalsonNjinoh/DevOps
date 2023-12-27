output "cloudfront_distribution_url" {
  description = "The URL of the CloudFront distribution."
  value       = "https://${aws_cloudfront_distribution.this.domain_name}"
}
output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.id
}
