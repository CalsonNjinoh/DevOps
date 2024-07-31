rules = [
  {
    name                = "SizeRestrictions_BODY"
    priority            = 0
    comparison_operator = "GE"
    size                = 100
    field_to_match      = "single_header"
    field_to_match_value= "sizerestrictions_body"  # Ensure this is lowercase and contains only valid characters
    text_transformation = "NONE"
    action              = "allow"
    vendor_name         = ""
    rule_group_name     = ""
    override_action     = ""
    metric_name         = "SizeRestrictions_BODY"
  },
  {
    name                = "AWS-AWSManagedRulesCommonRuleSet"
    priority            = 1
    comparison_operator = "EQ"  # Dummy value since it is required
    size                = 0
    field_to_match      = "single_header"
    field_to_match_value= "host"  # Example valid header name
    text_transformation = "NONE"
    action              = "count"
    vendor_name         = "AWS"
    rule_group_name     = "AWSManagedRulesCommonRuleSet"
    override_action     = "none"
    metric_name         = "AWS-AWSManagedRulesCommonRuleSet"
  },
  {
    name                = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority            = 2
    scope               = "REGIONAL"
    comparison_operator = "EQ"  # Dummy value since it is required
    size                = 0
    field_to_match      = "single_header"
    field_to_match_value= "host"  # Example valid header name
    text_transformation = "NONE"
    action              = "count"
    vendor_name         = "AWS"
    rule_group_name     = "AWSManagedRulesAmazonIpReputationList"
    override_action     = "none"
    metric_name         = "AWS-AWSManagedRulesAmazonIpReputationList"
  }
]

alb_arn = "arn:aws:elasticloadbalancing:ca-central-1:762372983622:loadbalancer/app/test/21b9f3ea3c17270b"
description = "WAF for test ALB"
environment = "us-east-1"
regions = ["us-east-1"]


whitelist_ip_addresses = {
  "us-east-1" = []
}

blacklist_ip_addresses_per_region = {
  "us-east-1" = []
}

create_blacklist_rule = {
  "us-east-1" = false
}
