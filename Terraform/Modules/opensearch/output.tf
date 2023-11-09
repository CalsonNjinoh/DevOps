output "domain_id" {
  description = "The ID of the OpenSearch domain."
  value       = aws_elasticsearch_domain.devtest.id
}
output "domain_endpoint" {
  description = "The endpoint of the OpenSearch domain."
  value       = aws_elasticsearch_domain.devtest.endpoint
}
output "security_group_ids" {
  description = "The ID of the security group"
  value       = var.security_group_ids
  
}
