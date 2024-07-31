/*variable "name" {
  description = "Name of the WAF"
  type        = string
}*/

/*variable "description" {
  description = "Description of the WAF"
  type        = string
}*/

/*variable "rules" {
  description = "List of rules for the WAF"
  type = list(object({
    name                = string
    priority            = number
    comparison_operator = string
    size                = number
    field_to_match      = string
    field_to_match_value= string
    text_transformation = string
    action              = string
    vendor_name         = string
    rule_group_name     = string
    override_action     = string
    metric_name         = string  # Added metric_name here
  }))
}*/

/*variable "alb_arn" {
  description = "ARN of the ALB to associate with WAF"
  type        = string
}*/


variable "name" {
  description = "Name of the WAF"
  type        = string
}

variable "description" {
  description = "Description of the WAF"
  type        = string
}

variable "rules" {
  description = "List of WAF rules"
  type        = list(map(string))
}

variable "alb_arn" {
  description = "ARN of the ALB"
  type        = string
}

variable "environment" {
  description = "The environment for which to create resources (e.g., dev, prod)"
  type        = string
}

variable "regions" {
  description = "List of regions where WAF rules should be applied"
  type        = list(string)
}

variable "whitelist_ip_addresses" {
  type = map(list(string))
}

variable "blacklist_ip_addresses_per_region" {
  description = "Map of regions to the list of IP addresses to blacklist"
  type        = map(list(string))

}

variable "create_blacklist_rule" {
  description = "Map of regions to boolean indicating whether to create a blacklist rule"
  type        = map(bool)
}
