output "vpc_id" {
  description = "VPC ID"
 value       = module.network.vpc_id
}
output "glaretram_instance_id" {
  description = "The ID of the Jenkins instance"
  value       = module.glaretram.instance_id
}
