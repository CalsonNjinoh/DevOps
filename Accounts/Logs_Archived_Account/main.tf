provider "aws" {
  region = "ca-central-1"
}

module "s3_centralized_logs" {
  source      = "../../modules/s3_centralized_logs"
  bucket_name = "dev-centralized-vpc-flow-logs-bucket"
}

output "archive_bucket_arn" {
  value = module.s3_centralized_logs.centralized_vpc_flow_logs_bucket_arn
}


#module "s3_vpc_flow_logs" {
  #source                  = "../../modules/s3_vpc_flow_logs"
  #bucket_name             = "my-vpc-flow-logs-bucket"
  #sandbox_account_id  = "762372983622"
#}
#module "s3_vpc_flow_logs" {
  #source                  = "../../modules/s3_vpc_flow_logs"
  #bucket_name             = "my-vpc-flow-logs-bucket"
  #staging_account_id  = "237781716992"
#}
