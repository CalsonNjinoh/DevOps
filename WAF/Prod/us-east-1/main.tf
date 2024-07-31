provider "aws" {
  region = "us-east-1"
}

/*module "waf" {
  source      = "../../modules/WAF"
  name        = var.name
  description = "us-east-rules"
  rules       = var.rules
  alb_arn     = var.alb_arn
  environment = var.environment
  regions     = var.regions
  whitelist_ip_addresses = var.ip_addresses_per_region
  blacklist_ip_addresses = var.blacklist_ip_addresses_per_region
  ip_addresses_per_region = var.ip_addresses_per_region
  blacklist_ip_addresses_per_region = var.blacklist_ip_addresses_per_region

  create_whitelist_rule = {
    for region in var.regions : region => false
  }
  create_blacklist_rule = {
    for region in var.regions : region => false
  }
}*/

module "waf" {
  source      = "../../modules/WAF"
  name        = var.name
  description = "IP_set_for_blacklisted_IPs_in_ca-central-1"
  rules       = var.rules
  alb_arn     = var.alb_arn
  environment = var.environment
  regions     = var.regions
  whitelist_ip_addresses = var.whitelist_ip_addresses
  blacklist_ip_addresses = var.blacklist_ip_addresses_per_region

  create_whitelist_rule = {
    for region in var.regions : region => false
  }
  create_blacklist_rule = {
    for region in var.regions : region => false
  }


  blacklist_ip_addresses_per_region = var.blacklist_ip_addresses_per_region
}
