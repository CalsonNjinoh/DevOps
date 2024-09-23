output "redis_security_group_id" {
  description = "The ID of the security group"
  value       = length(aws_security_group.redis) > 0 ? aws_security_group.redis[0].id : null
}

output "mqtt_security_group_id" {
  description = "The ID of the security group"
  value       = length(aws_security_group.mqtt) > 0 ? aws_security_group.mqtt[0].id : null
}

output "elephant_security_group_id" {
  description = "The ID of the security group"
  value       = length(aws_security_group.elephants) > 0 ? aws_security_group.elephants[0].id : null
}

output "nginx_security_group_id" {
  description = "The ID of the security group"
  value       = length(aws_security_group.nginx) > 0 ? aws_security_group.nginx[0].id : null
}

output "registration_security_group_id" {
  description = "The ID of the security group"
  value       = length(aws_security_group.registration_server) > 0 ? aws_security_group.registration_server[0].id : null
}

output "ssh_security_group_id" {
  description = "The ID of the security group"
  value       = length(aws_security_group.ssh) > 0 ? aws_security_group.ssh[0].id : null
}

output "api_security_group_id" {
  description = "The ID of the security group"
  value       = length(aws_security_group.api) > 0 ? aws_security_group.api[0].id : null
}

output "alb_security_group_id" {
  description = "The ID of the security group"
  value       = length(aws_security_group.alb) > 0 ? aws_security_group.alb[0].id : null
}

output "backup_security_group_id" {
  description = "The ID of the security group"
  value       = length(aws_security_group.backups) > 0 ? aws_security_group.backups[0].id : null
}

output "vpn_security_group_id" {
  description = "The ID of the security group"
  value       = length(aws_security_group.vpn) > 0 ? aws_security_group.vpn[0].id : null
}

output "opensearch_security_group_id" {
  description = "The ID of the security group"
  value       = length(aws_security_group.opensearch) > 0 ? aws_security_group.opensearch[0].id : null
}

output "backend_services_security_group_id" {
  description = "The ID of the security group"
  value       = length(aws_security_group.backend-services) > 0 ? aws_security_group.backend-services[0].id : null
}

output "lambda_vpc_security_group_id" {
  description = "The ID of the Lambda VPC security group"
  value       = length(aws_security_group.lambda_sg) > 0 ? aws_security_group.lambda_sg[0].id : null
}
