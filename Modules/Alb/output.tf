output "alb_dns_name" {
  description = "DNS name for the ALB"
  value       = aws_lb.glaretram_alb.dns_name
}
output "alb_arn" {
  description = "ARN for the ALB"
  value       = aws_lb.glaretram_alb.arn
}

output "load_balancer_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.glaretram_alb.arn
}
