#region              = "ca-central-1"
#alb_name            = "my-alb"
#alb_internal        = false
#alb_type            = "application"
#alb_subnets         = ["subnet-0bb1c79de3EXAMPLE", "subnet-0123456789EXAMPLE"]
#alb_security_groups = ["sg-0123456789EXAMPLE"]
#tg_name             = "my-target-group"
#tg_port             = 80
#tg_protocol         = "HTTP"
#vpc_id              = "vpc-0123456789EXAMPLE"
#acm_certificate_arn = "arn:aws:acm:region:account-id:certificate/certificate-id"


# jenkins new configuration 

region          = "ca-central-1"
name            = "Development"
cidr            = "10.20.0.0/16"
azs             = ["ca-central-1a", "ca-central-1b", "ca-central-1d"]
public_subnets  = ["10.20.10.0/24", "10.20.11.0/24", "10.20.12.0/24"]
private_subnets = ["10.20.13.0/24", "10.20.14.0/24", "10.20.15.0/24"]
key_path        = "~/.ssh/id_rsa.pub"

tags = {
  "Environment" = "Shared-Service-Account"
  "Type"        = "Shared-Service-Account"
}



#####################################

public_domain_name  = "aetonix.xyz"
//private_domain_name = "aetonix.xyz"
//vpc_id              = "vpc-01bb6e0a889a748c9"
public_records      = {
  "apps.dev" = {
    type    = "CNAME"
    ttl     = "900"
    records = ["d3hl8hcir54sif.cloudfront.net."]
  },
  "dashboard.dev" = {
    type    = "CNAME"
    ttl     = "5"
    records = ["d3hl8hcir54sif.cloudfront.net."]
  },
  "pathways.dev" = {
    type    = "CNAME"
    ttl     = "5"
    records = ["dj1hy3shazdci.cloudfront.net."]
  }
}
