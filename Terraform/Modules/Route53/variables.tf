variable "public_domain_name" {
  description = "The domain name for the public hosted zone."
  type        = string
}
//variable "private_domain_name" {
  //description = "The domain name for the private hosted zone."
  //type        = string
//}

variable "vpc_id" {
  description = "The VPC ID associated with the hosted zones."
  type        = string
}
variable "public_records" {
  description = "Map of DNS records to create in the public hosted zone."
  type        = map(any)
  default     = {}
}

//variable "private_records" {
  //description = "Map of DNS records to create in the private hosted zone."
  //type        = map(any)
  //default     = {}
//}
