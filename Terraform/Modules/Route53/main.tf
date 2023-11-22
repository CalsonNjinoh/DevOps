
//Import the existing public hosted zone
resource "aws_route53_zone" "public" {
  name   = var.public_domain_name
}
// Create a new private hosted zone
//resource "aws_route53_zone" "private" {
 // name   = var.private_domain_name
  //vpc {
   // vpc_id = var.vpc_id
  //}
 // #private_zone = true
//}

// Create records in the public hosted zone

resource "aws_route53_record" "public_record" {
  for_each = var.public_records
  zone_id  = aws_route53_zone.public.zone_id
  name     = each.key
  type     = each.value.type
  ttl      = each.value.ttl
  records  = each.value.records
}

// Create records in the private hosted zone
//resource "aws_route53_record" "private_record" {
  //for_each = var.private_records
  //zone_id  = aws_route53_zone.private.zone_id
  //name     = each.key
  //type     = each.value.type
  //ttl      = each.value.ttl
  //records  = each.value.records
//}
