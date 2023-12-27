variable "subnets" {
  description = "List of subnets for the ALB"
  type        = list(string)
}
variable "vpc_id" {
  description = "VPC ID where Jenkins runs"
  type        = string
}
variable "alb_security_group" {
  description = "Security Group for the ALB"
  type        = string
}
variable "glaretram_ec2_instance_id" {
  description = "The EC2 instance ID for glaretram"
  type        = string
}
variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for the ALB"
  type        = string
  
}
variable "alb_dns_name" {
  description = "The DNS name of the ALB"
  type        = string
}
