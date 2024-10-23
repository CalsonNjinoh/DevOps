region          = "eu-west-2"
name            = "Reporting-EU-West-2"
cidr            = "10.28.0.0/16"
azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
public_subnets  = ["10.28.20.0/24", "10.28.21.0/24", "10.28.22.0/24"]
private_subnets = ["10.28.23.0/24", "10.28.24.0/24", "10.28.25.0/24"]
key_path        = "~/.ssh/id_rsa.pub"


tags = {
  "Environment" = "Production-EU"
  "Type"        = "Production"
}

environment = "production"  
centralized_vpc_flow_logs_bucket_arn = "arn:aws:s3:::reporting-acct-vpc-uk-centralized-flowlogs"

# Environment variables for Lambda

ORG       = "62388f1c573a6e53f095fbfa"
BUCKETORG = "62549a840c5fbf60d7f45b6d"
WORKFLOW  = "60b0565688ce331e2cdc09ab"

/*################
# VPC PEERING
################
//test with dev account
peer_vpc_id   = "vpc-082611cca138a882a" 
peer_owner_id = "973334512903"
peer_cidr_block = "10.197.0.0/16"*/
