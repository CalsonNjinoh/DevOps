output "alb_dns_name" {
  description = "DNS name for the ALB"
  value       = aws_lb.glaretram_alb.dns_name
}
output "alb_arn" {
  description = "ARN for the ALB"
  value       = aws_lb.glaretram_alb.arn
}
