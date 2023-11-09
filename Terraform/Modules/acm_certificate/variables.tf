variable "domain_name" {
  description = "The domain name for the ACM certificate."
  type        = string
}
variable "tags" {
  description = "Tags to apply to the ACM certificate."
  type        = map(string)
  default     = {}
}
variable "region" {
  description = "The AWS region in which to create the ACM certificate."
  type        = string 
}
