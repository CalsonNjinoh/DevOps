name        = "canadawaf-prod"
description = "WAF for ca-central-1"
alb_arn     = "arn:aws:elasticloadbalancing:ca-central-1:891377304437:loadbalancer/app/jenkins/dd293a4feab4a652"

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
    field_to_match      = ""
    field_to_match_value= ""
    text_transformation = "NONE"
    action              = ""
    vendor_name         = "AWS"
    rule_group_name     = "AWSManagedRulesCommonRuleSet"
    override_action     = "none"
    metric_name         = "AWS-AWSManagedRulesCommonRuleSet"
  },
  {
    name                = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority            = 2
    comparison_operator = "EQ"  # Dummy value since it is required
    size                = 0
    field_to_match      = ""
    field_to_match_value= ""
    text_transformation = "NONE"
    action              = ""
    vendor_name         = "AWS"
    rule_group_name     = "AWSManagedRulesAmazonIpReputationList"
    override_action     = "none"
    metric_name         = "AWS-AWSManagedRulesAmazonIpReputationList"
  }
]
