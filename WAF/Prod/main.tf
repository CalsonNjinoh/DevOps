provider "aws" {
  region = "ca-central-1"
}

module "waf" {
  source      = "../../modules/WAF"
  name        = var.name
  description = var.description
  rules       = var.rules
  alb_arn     = var.alb_arn
}
