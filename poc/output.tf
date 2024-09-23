/*output "redis_security_group_id" {
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
}*/

#######################################################
# Outputs for all Security Groups
#######################################################

# Default Security Group
output "default_sg_id" {
  value       = aws_default_security_group.default[0].id
  description = "The ID of the Default Security Group"
  condition   = var.create_default_sg
}

# Redis Security Group
output "redis_sg_id" {
  value       = aws_security_group.redis[0].id
  description = "The ID of the Redis Security Group"
  condition   = var.create_redis_sg
}

output "redis_vpc_rule_id" {
  value       = aws_security_group_rule.redis-vpc[0].id
  description = "The ID of the Redis VPC rule"
  condition   = var.create_redis_sg
}

output "redis_backups_rule_id" {
  value       = aws_security_group_rule.redis-backups[0].id
  description = "The ID of the Redis Backups rule"
  condition   = var.create_redis_sg
}

output "redis_vpn_rule_id" {
  value       = aws_security_group_rule.redis-vpn[0].id
  description = "The ID of the Redis VPN rule"
  condition   = var.create_redis_sg
}

# MQTT Security Group
output "mqtt_sg_id" {
  value       = aws_security_group.mqtt[0].id
  description = "The ID of the MQTT Security Group"
  condition   = var.create_mqtt_sg
}

output "mqtt_vpc_rule_id" {
  value       = aws_security_group_rule.mqtt-vpc[0].id
  description = "The ID of the MQTT VPC rule"
  condition   = var.create_mqtt_sg
}

output "mqtt_vpn_rule_id" {
  value       = aws_security_group_rule.mqtt-vpn[0].id
  description = "The ID of the MQTT VPN rule"
  condition   = var.create_mqtt_sg
}

# Elephants Security Group
output "elephants_sg_id" {
  value       = aws_security_group.elephants[0].id
  description = "The ID of the Elephants Security Group"
  condition   = var.create_elephants_sg
}

output "elephants_ingress_rule_id" {
  value       = aws_security_group_rule.elephants-in[0].id
  description = "The ID of the Elephants ingress rule"
  condition   = var.create_elephants_sg
}

output "elephants_egress_rule_id" {
  value       = aws_security_group_rule.elephants-out[0].id
  description = "The ID of the Elephants egress rule"
  condition   = var.create_elephants_sg
}

# NGINX Security Group
output "nginx_sg_id" {
  value       = aws_security_group.nginx[0].id
  description = "The ID of the NGINX Security Group"
  condition   = var.create_nginx_sg
}

output "nginx_alb_rule_id" {
  value       = aws_security_group_rule.nginx-alb[0].id
  description = "The ID of the NGINX ALB rule"
  condition   = var.create_nginx_sg
}

# Registration Server Security Group
output "registration_server_sg_id" {
  value       = aws_security_group.registration_server[0].id
  description = "The ID of the Registration Server Security Group"
  condition   = var.create_registration_server_sg
}

output "registration_server_alb_rule_id" {
  value       = aws_security_group_rule.registration_server_alb[0].id
  description = "The ID of the Registration Server ALB rule"
  condition   = var.create_registration_server_sg
}

# SSH Security Group
output "ssh_sg_id" {
  value       = aws_security_group.ssh[0].id
  description = "The ID of the SSH Security Group"
  condition   = var.create_ssh_sg
}

output "ssh_rule_id" {
  value       = aws_security_group_rule.ssh[0].id
  description = "The ID of the SSH rule"
  condition   = var.create_ssh_sg
}

# API Security Group
output "api_sg_id" {
  value       = aws_security_group.api[0].id
  description = "The ID of the API Security Group"
  condition   = var.create_api_sg
}

output "api_alb_rule_id" {
  value       = aws_security_group_rule.api-alb[0].id
  description = "The ID of the API ALB rule"
  condition   = var.create_api_sg
}

# ALB Security Group
output "alb_sg_id" {
  value       = aws_security_group.alb[0].id
  description = "The ID of the ALB Security Group"
  condition   = var.create_alb_sg
}

output "alb_api_rule_id" {
  value       = aws_security_group_rule.alb-api[0].id
  description = "The ID of the ALB API rule"
  condition   = var.create_alb_sg
}

output "alb_registration_rule_id" {
  value       = aws_security_group_rule.alb-registration[0].id
  description = "The ID of the ALB Registration rule"
  condition   = var.create_alb_sg
}

output "alb_files_rule_id" {
  value       = aws_security_group_rule.alb-files[0].id
  description = "The ID of the ALB Files rule"
  condition   = var.create_alb_sg
}

# Backups Security Group
output "backups_sg_id" {
  value       = aws_security_group.backups[0].id
  description = "The ID of the Backups Security Group"
  condition   = var.create_backups_sg
}

# VPN Security Group
output "vpn_sg_id" {
  value       = aws_security_group.vpn[0].id
  description = "The ID of the VPN Security Group"
  condition   = var.create_vpn_sg
}

output "vpn_redis_rule_id" {
  value       = aws_security_group_rule.vpn-redis[0].id
  description = "The ID of the VPN Redis rule"
  condition   = var.create_vpn_sg
}

output "vpn_ssh_rule_id" {
  value       = aws_security_group_rule.vpn-ssh[0].id
  description = "The ID of the VPN SSH rule"
  condition   = var.create_vpn_sg
}

output "vpn_mqtt_rule_id" {
  value       = aws_security_group_rule.vpn-mqtt[0].id
  description = "The ID of the VPN MQTT rule"
  condition   = var.create_vpn_sg
}

output "vpn_postgres_rule_id" {
  value       = aws_security_group_rule.vpn-postgres[0].id
  description = "The ID of the VPN Postgres rule"
  condition   = var.create_vpn_sg
}

output "vpn_opensearch_rule_id" {
  value       = aws_security_group_rule.vpn-opensearch[0].id
  description = "The ID of the VPN OpenSearch rule"
  condition   = var.create_vpn_sg
}

# OpenSearch Security Group
output "opensearch_sg_id" {
  value       = aws_security_group.opensearch[0].id
  description = "The ID of the OpenSearch Security Group"
  condition   = var.create_opensearch_sg
}

output "opensearch_ingress_rule_opensearch_port_id" {
  value       = aws_security_group_rule.opensearch-vpn-ingress-opensearch-port[0].id
  description = "The ID of the OpenSearch VPN Ingress rule for OpenSearch port"
  condition   = var.create_opensearch_sg
}

output "opensearch_ingress_rule_https_port_id" {
  value       = aws_security_group_rule.opensearch-vpn-ingress-https-port[0].id
  description = "The ID of the OpenSearch VPN Ingress rule for HTTPS port"
  condition   = var.create_opensearch_sg
}

output "opensearch_ingress_rule_http_port_id" {
  value       = aws_security_group_rule.opensearch-vpn-ingress-http-port[0].id
  description = "The ID of the OpenSearch VPN Ingress rule for HTTP port"
  condition   = var.create_opensearch_sg
}

output "opensearch_vpc_ingress_rule_id" {
  value       = aws_security_group_rule.opensearch-vpc-ingress[0].id
  description = "The ID of the OpenSearch VPC Ingress rule"
  condition   = var.create_opensearch_sg
}

output "opensearch_egress_rule_id" {
  value       = aws_security_group_rule.opensearch-egress[0].id
  description = "The ID of the OpenSearch Egress rule"
  condition   = var.create_opensearch_sg
}

# Backend Services Security Group
output "backend_services_sg_id" {
  value       = aws_security_group.backend-services[0].id
  description = "The ID of the Backend Services Security Group"
  condition   = var.create_backend_services_sg
}

output "backend_services_mongo_rule_id" {
  value       = aws_security_group_rule.backend-services-mongo[0].id
  description = "The ID of the Backend Services MongoDB rule"
  condition   =
