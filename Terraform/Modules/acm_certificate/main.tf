
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags              = var.tags
  lifecycle {
    create_before_destroy = true
  }
}
output "validation_dns_records" {
  description = "The DNS validation records for the ACM certificate."
  value       = aws_acm_certificate.cert.domain_validation_options
}
