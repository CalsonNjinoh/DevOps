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
