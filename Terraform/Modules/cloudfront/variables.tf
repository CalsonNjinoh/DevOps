variable "http_version" {
  description = "The maximum HTTP version to support on the CloudFront distribution."
  type        = string
  default     = "http2"
}
variable "domain_name" {
  description = "The domain name of the S3 bucket for the CloudFront distribution."
  type        = string
}
variable "origin_access_identity" {
  description = "The origin access identity for the S3 bucket."
  type        = string
}
variable "price_class" {
  description = "The price class for the CloudFront distribution."
  type        = string
  default     = "PriceClass_200"
}
variable "security_policy" {
  description = "The security policy for the CloudFront distribution."
  type        = string
  default     = "TLSv1.2_2021"
}
variable "http_versions" {
  description = "HTTP versions supported by the CloudFront distribution."
  type        = string
  default     = "http2"
}
variable "cloudfront_distributions" {
  description = "List of CloudFront distributions' domain names and zone IDs"
  type = list(object({
    domain_name = string
    zone_id     = string
    subdomain   = string
  }))
  default = []
}
variable "aliases" {
  description = "List of aliases for the CloudFront distribution"
  type        = list(string)
  default     = []
}
variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate to use for the CloudFront distribution"
  type        = string
}
variable "ssl_support_method" {
  description = "The method to use for SSL support"
  type        = string
  default     = "sni-only"
}
variable "minimum_protocol_version" {
  description = "The minimum protocol version to support for SSL connections"
  type        = string
  default     = "TLSv1.2_2021"
}
