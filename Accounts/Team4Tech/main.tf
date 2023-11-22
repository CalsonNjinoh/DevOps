## zone id can be vebalarized and passed in from the management account

provider "aws" {
  region = "ca-central-1"
}
module "iam_role_route53_access" {
  source = "../../modules/iam_role_route53_access"
}
resource "aws_route53_record" "jenkins_cname" {
  zone_id = "Z00529321UWQEXNB0QHTE"
  name    = "jenkins.aetonix.xyz"
  type    = "CNAME"
  records = [var.jenkins_alb_dns_name]
  ttl     = 300
  }
resource "aws_route53_record" "ldap_cname" {
  zone_id = "Z00529321UWQEXNB0QHTE"
  name    = "ldap.aetonix.xyz"
  type    = "CNAME"
  records = [var.jenkins_alb_dns_name]
  ttl     = 300
}
resource "aws_route53_record" "dashboard_cloudfront_cname" {
  zone_id = "Z00529321UWQEXNB0QHTE"
  name    = "devdashboard.aetonix.xyz"
  type    = "CNAME"
  records = ["d2hzt0nga0wkoy.cloudfront.net"]
  ttl     = 300
}
resource "aws_route53_record" "devapp_cloudfront_cname" {
  zone_id = "Z00529321UWQEXNB0QHTE"
  name    = "appdev.aetonix.xyz"
  type    = "CNAME"
  records = ["dwwzavo0i79hi.cloudfront.net"]
  ttl     = 300
}
