resource "aws_wafv2_ip_set" "whitelist" {
  for_each = toset(var.regions)
  name     = "${each.key}-whitelist"
  scope    = "REGIONAL"
  ip_address_version = "IPV4"
  addresses = lookup(var.whitelist_ip_addresses, each.key, [])
}

resource "aws_wafv2_ip_set" "blacklist" {
  for_each = toset(var.regions)
  name     = "${each.key}-blacklist"
  scope    = "REGIONAL"
  ip_address_version = "IPV4"
  addresses = lookup(var.blacklist_ip_addresses, each.key, [])
}

resource "aws_wafv2_web_acl" "this" {
  for_each = toset(var.regions)

  name        = "waf-${each.key}-${var.environment}"
  scope       = "REGIONAL"
  description = "WAF_for_test_ALB_in_${each.key}_${var.environment}"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = var.create_whitelist_rule[each.key] ? [1] : []
    content {
      name     = "WhitelistRule"
      priority = 0

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
      priority = 1

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
    priority = 2

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
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
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
    priority = 4

    action {
      block {}
    }

    statement {
      size_constraint_statement {
        comparison_operator = "GT"
        size                = 1024
        field_to_match {
          body {}
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

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf-${each.key}-${var.environment}"
    sampled_requests_enabled   = true
  }
}
