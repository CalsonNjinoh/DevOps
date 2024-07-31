output "web_acl_ids" {
  value = { for k, v in aws_wafv2_web_acl.this : k => v.id }
}
