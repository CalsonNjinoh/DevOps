resource "aws_wafv2_ip_set" "whitelist" {
  for_each = toset(var.regions)
  name     = "${each.key}-whitelist"
  scope    = var.scope
  ip_address_version = "IPV4"
  addresses = lookup(var.whitelist_ip_addresses, each.key, [])
}

resource "aws_wafv2_ip_set" "blacklist" {
  for_each = toset(var.regions)
  name     = "${each.key}-blacklist"
  scope    = var.scope
  ip_address_version = "IPV4"
  addresses = lookup(var.blacklist_ip_addresses, each.key, [])
}

resource "aws_wafv2_web_acl" "this" {
  for_each = toset(var.regions)

  name        = "waf-${each.key}-${var.environment}"
  scope       = var.scope
  description = "WAF_${each.key}_${var.environment}"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = var.create_whitelist_rule[each.key] ? [1] : []
    content {
      name     = "WhitelistRule"
      priority = lookup(var.rule_priorities[each.key], "WhitelistRule", 0)

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.whitelist[each.key].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "WhitelistRule"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.create_blacklist_rule[each.key] ? [1] : []
    content {
      name     = "BlacklistRule"
      priority = lookup(var.rule_priorities[each.key], "BlacklistRule", 1)

      action {
        block {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.blacklist[each.key].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "BlacklistRule"
        sampled_requests_enabled   = true
      }
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = lookup(var.rule_priorities[each.key], "AWSManagedRulesAmazonIpReputationList", 2)

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = lookup(var.rule_priorities[each.key], "AWSManagedRulesCommonRuleSet", 3)

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"

        rule_action_override {
          name = "NoUserAgent_HEADER"
          action_to_use {
            allow {}
          }
        }

        rule_action_override {
          name = "SizeRestrictions_QUERYSTRING"
          action_to_use {
            allow {}
          }
        }

        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            allow {}
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "SizeRestrictions_BODY"
    priority = lookup(var.rule_priorities[each.key], "SizeRestrictions_BODY", 4)

    action {
      allow {}
    }

    statement {
      size_constraint_statement {
        comparison_operator = "GE"
        size                = 0
        field_to_match {
          single_header {
            name = "size_restrictions_body"
          }
        }
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SizeRestrictions_BODY"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "Files"
    priority = lookup(var.rule_priorities[each.key], "Files", 5)

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          not_statement {
            statement {
              geo_match_statement {
                country_codes = ["CA"]
              }
            }
          }
        }
        statement {
          byte_match_statement {
            field_to_match {
              single_header {
                name = "host"
              }
            }
            positional_constraint = "EXACTLY"
            search_string         = "files.aetonix.xyz"
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Files"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf-${each.key}-${var.environment}"
    sampled_requests_enabled   = true
  }
}
