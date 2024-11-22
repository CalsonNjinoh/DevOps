provider "aws" {
  region = "ca-central-1"
}


########################################
# Create VPC, Subnets, Route Tables
########################################

module "network" {
  source = "../../../terraform-modules/vpc"
  name   = var.name

  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  azs  = var.azs
  cidr = var.cidr

  public_subnets                       = var.public_subnets
  private_subnets                      = var.private_subnets
  tags                                 = var.tags
#  security_group_ids                   = []
  centralized_vpc_flow_logs_bucket_arn = var.centralized_vpc_flow_logs_bucket_arn
  cloudwatch_log_group_arn             = module.network.cloudwatch_log_group_arn
  max_aggregation_interval             = 60
  log_retention_days                   = 365
 vpc_flow_logs_role_arn                = "arn:aws:iam::762372983622:role/vpcFlowLogsRole_ca-central-1"
  
  
}


########################################  
# EventBridge
########################################

module "eventbridge" {
  source                        = "git::git@github.com:Aetonix/terraform-modules.git//eventbridge?ref=main"
  environment                   = "logs-archive-${var.region}"
  sns_topic_arn                 = module.sns_notify_lambda.sns_topic_arn
  enable_guardduty              = true
  create_eventbridge_scheduler  = true
  schedule_name                 = "run-lambda-vpcflow-logs-query"
  schedule_description          = "Schedule to run Lambda for VPC flow log queries"
  schedule_pattern              = "cron(14 0 ? * MON-FRI *)"
  create_lambda_resources       = true
  function_name                 = "vpc-flow-log-query-lambda"
  lambda_function_arn           = module.eventbridge.lambda_function_arn
  handler                       = "index.handler"	
  runtime                       = "python3.12"
  excluded_rule_names           = []
  rules_config                  = []
  
}


module "sns_notify_lambda" {
  source = "git::git@github.com:Aetonix/terraform-modules.git//slack-notify-lambda?ref=main"
  env    = var.name
}


module "iam_policies" {
  source                                       = "../../../terraform-modules/iam-policies"
  //secrets_arn                                  = data.aws_secretsmanager_secret.backend.arn
  //firebase_arn                                 = data.aws_secretsmanager_secret.firebase.arn
  env                                          = var.name
  create_chime_policy                          = true
  create_secrets_policy                        = true
  create_backup_policy                         = true
  create_cloudwatch_agent_policy               = true
  create_assume_cross_account_role_policy      = true
  create_s3_data_uploads_us_policy             = true
  create_systems_manager_get_parameters_policy = true
  create_vpc_flow_logs_policy                  = true
  //secrets_encryption_key_arn                   = data.aws_kms_key.secrets_key.arn
  //backup_bucket_arn                            = var.backups_bucket_arn
  //cloudwatch_agent_role                        = var.cloudwatch_agent_role
}

module "iam" {
  source = "git::git@github.com:Aetonix/terraform-modules.git//iam?ref=main"
  tags   = var.tags
  name   = var.name
}
module "iam_ssm_lambda" {
  source              = "git::git@github.com:Aetonix/terraform-modules.git//iam-roles?ref=main"
  create_ssm_role     = true
  create_backend_role = true
  create_backup_role  = true
  create_vpc_flow_logs_role = true

  //OU  = var.account_OU
  env = var.env
  policies_for_backend_role = [
    {
      policy_arn = module.iam_policies.secrets_policy
    },
    {
      policy_arn = module.iam_policies.chime_policy
    },
    {
      policy_arn = module.iam_policies.cloudwatch_agent_policy
    }
  ]
  backup_role_policies = [
    {
      policy_arn = module.iam_policies.secrets_policy
    },
    {
      policy_arn = module.iam_policies.backup_policy
    },
    {
      policy_arn = module.iam_policies.cloudwatch_agent_policy
    }
  ]
  ssm_role_policies = [
    {
      policy_arn = module.iam_policies.cloudwatch_agent_policy
    }
  ]
  policies_for_production_role = [
    {
      policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    },
    {
      policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    },
    {
      policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
    },
    {
      policy_arn = module.iam_policies.s3_data_uploads_us_arn
    },
    {
      policy_arn = module.iam_policies.systems_manager_get_parameters_arn
    }
  ]
  policies_for_vpc_flow_logs_role = [
    {
      policy_arn = module.iam_policies.vpc_flow_logs_policy_arn
    }
  ]
}
