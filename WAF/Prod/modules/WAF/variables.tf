variable "name" {
  description = "Name of the WAF"
  type        = string
}

variable "description" {
  description = "Description of the WAF"
  type        = string
}

variable "rules" {
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
    metric_name         = string  # Add metric_name here
  }))
}

variable "alb_arn" {
  description = "ARN of the ALB to associate with WAF"
  type        = string
}

variable "regions" {
  description = "List of regions where WAF rules should be applied"
  type        = list(string)
}

/**variable "ip_addresses_per_region" {
  description = "Map of regions to the list of IP addresses to whitelist"
  type        = map(list(string))
}**/

variable "blacklist_ip_addresses_per_region" {
  description = "Map of regions to the list of IP addresses to blacklist"
  type        = map(list(string))
}

variable "environment" {
  description = "The environment for which to create resources (e.g., dev, prod)"
  type        = string
}

variable "create_whitelist_rule" {
  description = "Map of regions to boolean indicating whether to create a whitelist rule"
  type        = map(bool)
}

variable "create_blacklist_rule" {
  description = "Map of regions to boolean indicating whether to create a blacklist rule"
  type        = map(bool)
}


variable "whitelist_ip_addresses" {
  type = map(list(string))
}

variable "blacklist_ip_addresses" {
  type = map(list(string))
}

variable "scope" {
  description = "Scope of the WAF"
  type        = string
  
}

variable "rule_priorities" {
  description = "Map of rule priorities for each region"
  type        = map(map(number))
  default     = {
    "ca-central-1" = {
      SizeRestrictions_BODY                 = 0
      WhitelistRule                         = 1
      AWSManagedRulesCommonRuleSet          = 4
      BlacklistRule                         = 5
      AWSManagedRulesAmazonIpReputationList = 6
       
    }
    "us-east-1" = {
      SizeRestrictions_BODY                 = 0
      AWSManagedRulesCommonRuleSet          = 1
      AWSManagedRulesAmazonIpReputationList = 2
      WhitelistRule                         = 3
      BlacklistRule                         = 4
      
     
    }
    "eu-west-2" = {
      SizeRestrictions_BODY                 = 0
      AWSManagedRulesCommonRuleSet          = 1
      AWSManagedRulesAmazonIpReputationList = 2
      WhitelistRule                         = 4
      BlacklistRule                         = 3
    }
  }
}
