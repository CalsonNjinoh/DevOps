output "public_hosted_zone_id" {
  description = "The ID of the public hosted zone."
  value       = module.route53.public_hosted_zone_id
}
//output "private_hosted_zone_id" {
  //description = "The ID of the private hosted zone."
  //value       = module.route53.private_hosted_zone_id
//}

output "dns_validation_records" {
  value = module.acm_certificate.validation_dns_records
}


#new configuration for jenkins

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}
output "jenkins_instance_id" {
  description = "The ID of the Jenkins instance"
  value       = module.jenkins.instance_id
}
output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.jenkins_alb.alb_dns_name
}
