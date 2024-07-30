resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  description = var.description
  scope       = "REGIONAL"
  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = true
  }

  dynamic "rule" {
    for_each = var.rules
    content {
      name     = rule.value.name
      priority = rule.value.priority
      statement {
        dynamic "size_constraint_statement" {
          for_each = rule.value.field_to_match != "" ? [rule.value] : []
          content {
            comparison_operator = size_constraint_statement.value.comparison_operator
            size                = size_constraint_statement.value.size
            field_to_match {
              single_header {
                name = replace(lower(size_constraint_statement.value.field_to_match_value), "/[^a-z0-9_-]/", "_")
              }
            }
            text_transformation {
              priority = 0
              type     = size_constraint_statement.value.text_transformation
            }
          }
        }
        dynamic "managed_rule_group_statement" {
          for_each = rule.value.vendor_name != "" && rule.value.rule_group_name != "" ? [rule.value] : []
          content {
            vendor_name = managed_rule_group_statement.value.vendor_name
            name        = managed_rule_group_statement.value.rule_group_name
          }
        }
      }
      action {
        allow {}
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.metric_name
        sampled_requests_enabled   = true
      }
    }
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
