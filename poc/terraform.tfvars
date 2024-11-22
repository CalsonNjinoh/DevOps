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

alb_arn = "arn:aws:elasticloadbalancing:us-east-1:762372983622:loadbalancer/app/test/8ea8bdbde9b68341"


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

create_files_rule = {
  "us-east-1" = false
}

create_many_file_requests_rule = {
  "us-east-1" = false
}

region          = "ca-central-1"
name            = "Development"
cidr            = "10.20.0.0/16"
azs             = ["ca-central-1a", "ca-central-1b", "ca-central-1d"]
public_subnets  = ["10.20.10.0/24", "10.20.11.0/24", "10.20.12.0/24"]
private_subnets = ["10.20.13.0/24", "10.20.14.0/24", "10.20.15.0/24"]


centralized_vpc_flow_logs_bucket_arn = "arn:aws:s3:::sandboxstate"

env = "ca-central-1"
