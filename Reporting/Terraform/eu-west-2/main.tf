provider "aws" {
  region = var.region
}

/*terraform {
  backend "s3" {
    bucket         = "reports-tfstate-file"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    role_arn       = "arn:aws:iam::338674575706:role/TF-Dynamo-CrossAcct-Role"
  }
}*/

########################################
# Create VPC, Subnets, Route Tables
########################################

module "network" {
  source = "git::git@github.com:Aetonix/terraform-modules.git//vpc?ref=main"
  name   = var.name

  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  azs  = var.azs
  cidr = var.cidr

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  
  tags            = var.tags
    security_group_ids = [module.security_groups.lambda_vpc_security_group_id]
  centralized_vpc_flow_logs_bucket_arn = var.centralized_vpc_flow_logs_bucket_arn
}



########################################
# Create Security Groups
########################################

module "security_groups" {
  source = "git::git@github.com:Aetonix/terraform-modules.git//security-group?ref=main"
  vpc_id             = module.network.vpc_id
  vpc_cidr           = var.cidr
  backup_private_ip  = false
  redis_private_ip   = false
  tags                          = var.tags
  create_lambda_sg              = true
  create_default_sg             = false
  create_alb_sg                 = false
  create_api_sg                 = false
  create_redis_sg               = false
  create_mqtt_sg                = false
  create_elephants_sg           = false
  create_nginx_sg               = false
  create_registration_server_sg = false
  create_ssh_sg                 = false
  create_backups_sg             = false
  create_vpn_sg                 = false
  create_opensearch_sg          = false
  create_backend_services_sg    = false

}


########################################
# VPC Peering
########################################

/*data "aws_caller_identity" "current" {}

resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = module.network.vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_owner_id = var.peer_owner_id 
  auto_accept   = false

  tags = {
    Name = "VPC Peering Connection"
  }
}
locals {
  private_route_table_map = {
    for idx, id in module.network.private_route_table_id : idx => id
  }
}
resource "aws_route" "route_to_peer" {
  for_each = local.private_route_table_map
  route_table_id         = each.value
  destination_cidr_block = var.peer_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}*/


########################################
# Create Required IAM Policies
########################################

module "iam_policies" {
  source                                       = "git::git@github.com:Aetonix/terraform-modules.git//iam-policies?ref=main"
  create_chime_policy                          = false
  create_secrets_policy                        = false
  create_backup_policy                         = false
  create_cloudwatch_agent_policy               = false
  create_workflow_logs_policy                  = false
  create_atlas_policy                          = false
  create_s3_data_uploads_us_policy             = false
  create_systems_manager_get_parameters_policy = false
  create_assume_cross_account_role_policy      = true


}

########################################
# Create Lambda Execution Role
########################################

module "iam_lambda" {
  source = "git::git@github.com:Aetonix/terraform-modules.git//iam-roles?ref=main"
  create_lambda_exec_role = true
  create_production_role   = false

  policies_for_lambda_exec_role = [
    {
        policy_arn = module.iam_policies.assume_cross_account_role_policy_arn
    },
    {
        policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    },
    {
        policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"

    },
    {
        policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
    } 
  ]
}


########################################
# Lambda Functions for Reporting US-East1
########################################

data "aws_ssm_parameter" "mongo" {
  name = "/lambdas-${var.environment}-mongo"
}

data "aws_ssm_parameter" "redis" {
  name = "/lambdas-${var.environment}-redis"
}

data "aws_ssm_parameter" "elastic" {
  name = "/lambdas-${var.environment}-elastic"
}

locals {
  lambda_functions = {
    "general-comms-report-production-export" = {
      source_dir              = "general-reports/comms-report"
      run_yarn                = false
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        ORG       = var.ORG
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = true
      eventbridge_rule_name   = "peer-support-uk-comms-report"
      eventbridge_schedule_expression = "cron(45 06 1 * ? *)"
      //orgGroup                = "60b133722003d45d5b477a84
      bucket                  = ""
    },
    "uk-calls-export-production-export" = {
      source_dir              = "uk-calls-export"
      run_yarn                = true
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        ORG       = var.ORG
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = true
      eventbridge_rule_name   = "uk-calls-export-scheduler"
      eventbridge_schedule_expression = "cron(59 23 ? * SUN *)"
      bucket                  = ""
    },
    "st-thomas-icu-recovery-part2-new-report-production-export" = {
      source_dir              = "st-thomas-icu-recovery/icu-recovery-part1-part2"
      run_yarn                = false
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 900
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        //ORG       = var.ORG
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = false
      eventbridge_rule_name   = "st-thomas-icu-recovery"
      eventbridge_schedule_expression = "cron(0 5 ? * 2#1 *)"
      bucket                  = ""
    },
    "heartbeat-production-export" = {
      source_dir              = "heartbeat"
      run_yarn                = true
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        //ORG       = var.ORG
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = true
      eventbridge_rule_name   = "heartbeat-5-mins"
      eventbridge_schedule_expression = "cron(0/5 * * * ? *)"
      bucket                  = ""
    },
    "mobile-updater-production-export" = {
      source_dir              = "mobile-banner-updater"
      run_yarn                = false
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        REDIS     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        //ORG       = var.ORG
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = true
      eventbridge_rule_name   = "mobile-updater-5-mins"
      eventbridge_schedule_expression = "cron(0/5 * * * ? *)"
      bucket                  = ""
    },
    "general-org-data-to-elastic-production-export" = {
      source_dir              = "org-data-elastic"
      run_yarn                = true
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        ELASTIC   = data.aws_ssm_parameter.elastic.value
        //ORG       = var.ORG
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = true
      eventbridge_rule_name   = "general-org-data-to-elastic-schedule"
      eventbridge_schedule_expression = "cron(59 3 * * ? *)"
      bucket                  = "general-org-data-to-elastic-production-us-east-1"
    },
    "general-org-data-production-export" = {
      source_dir              = "general-reports/org-data"
      run_yarn                = false
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        ORG       = var.ORG
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = true
      eventbridge_rule_name   = "general-org-data-reports-schedule"
      description             = "Schedule for general org data reports"
      eventbridge_schedule_expression = "cron(59 3 * * ? *)"
      bucket                  = "general-org-data-production-us-east-1"
    },
    "uk-calls-export-culm-production-export" = {
      source_dir              = "uk-calls-export-culm"
      run_yarn                = true
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        ORG       = var.ORG
        UPLOADORG = "62388f1c573a6e53f095fbfa"
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = true
      eventbridge_rule_name   = "uk-calls-culm-export-scheduler"
      eventbridge_schedule_expression = "cron(59 23 ? * SUN *)"
      bucket                  = ""
    },
    "st-thomas-icu-recovery-part1-new-report-production-export" = {
      source_dir              = "st-thomas-icu-recovery/icu-recovery-part1-part2"
      run_yarn                = false
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        ORG       = "5e7fbeccc6b62410ff09e91d"
        ORGGROUP  = "5e7fc16dc6b62410ff09e94a"
        TZ        = "Europe/London"
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = true
      eventbridge_rule_name   = "st-thomas-icu-recovery"
      description             = "Schedules the invocation of ICU Recovery Part 2 report"
      eventbridge_schedule_expression = "cron(30 6 1 * ? *)"
      bucket                  = ""
    },
    "st-thomas-icu-recovery-part3-report-production-export" = {
      source_dir              = "st-thomas-icu-recovery/icu-recovery-part3-new"
      run_yarn                = false
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        ORG       = "5e7fbeccc6b62410ff09e91d"
        TZ        = "Europe/London"
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = false
      eventbridge_rule_name   = "st-thomas-icu-recovery-part3-report"
      eventbridge_schedule_expression = "cron(59 23 ? * SUN *)"
      bucket                  = ""
    },
    "gstt-inactive-production-export" = {
      source_dir              = "gstt-inactive-report"
      run_yarn                = false
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        //ORG       = var.ORG
        ORGANIZATION = "5e7fbeccc6b62410ff09e91d"
        ORGGROUP     = "5e7fc16dc6b62410ff09e94a"
        //BUCKETORG    = var.BUCKETORG
        //WORKFLOW     = var.WORKFLOW
      }
      enable_eventbridge      = false
      eventbridge_rule_name   = "gstt-inactive-report"
      eventbridge_schedule_expression = "cron(59 23 ? * SUN *)"
      bucket                  = ""
    },
    "st-thomas-icu-diary-report-production-export" = {
      source_dir              = "st-thomas-icu-diary"
      run_yarn                = false
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        //ORG       = var.ORG
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = false
      eventbridge_rule_name   = "st-thomas-icu-diary"
      eventbridge_schedule_expression = "cron(59 23 ? * SUN *)"
      bucket                  = ""
    },
    "icu-diary-pdf-production-export" = {
      source_dir              = "icu-diary-pdf"
      run_yarn                = false
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        CA        = "lambdas-${var.environment}-ca"
        CERT      = "lambdas-${var.environment}-cert"
        ELEPHANT_API = "elephant1.ops.in.uk.aetonix.xyz:43616"
        ELEPHANT_FILES = "https://files.uk.aetonix.xyz"
        FORM           = "61729d88d67a2d5815d5c8ce"
        KEY            = "lambdas-${var.environment}-key"
        NODE_TLS_REJECT_UNAUTHORIZED = "0"
        REGION        = "var.region"
        //ORG       = var.ORG
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = false
      eventbridge_rule_name   = "icu-diary-pdf"
      eventbridge_schedule_expression = "cron(59 23 ? * SUN *)"
      bucket                  = "icu-diary-pdf-production-export"
    },
    "general-calls-report-production-export" = {
      source_dir              = "general-calls"
      run_yarn                = false
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        //ORG       = var.ORG
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = true
      eventbridge_rule_name   = "general-calls-report"
      eventbridge_schedule_expression = "cron(59 23 ? * SUN *)"
      bucket                  = "coh-export-icu-production-us-east-1"
    },
    "access-audit-report-production-export" = {
      source_dir              = "access-audit-reports"
      run_yarn                = true
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-internal-reports"
        REGION    = "eu-west-2"
        //ORG       = var.ORG
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW

      }
      enable_eventbridge      = false
      eventbridge_rule_name   = "access-audit-production"
      eventbridge_schedule_expression = "cron(0 5 ? * 2#1 *)"
      bucket                  = ""
    },
    "embed-care-report-production-export" = {
      source_dir              = "embed-care"
      run_yarn                = false
      compile_typescript      = false
      handler                 = "src/index.handler"
      runtime                 = "nodejs16.x"
      role_arn                = module.iam_lambda.lambda_role_arn
      timeout                 = 899
      environment_variables   = {
        MONGO     = data.aws_ssm_parameter.mongo.value
        ENV       = "production"
        BUCKET    = "aetonix-reports-${var.environment}-${var.region}"
        //ORG       = var.ORG
        //BUCKETORG = var.BUCKETORG
        //WORKFLOW  = var.WORKFLOW
      }
      enable_eventbridge      = true
      eventbridge_rule_name   = "embed-care-production"
      eventbridge_schedule_expression = "cron(59 23 ? * SUN *)"
      bucket                  = "embed-care-production-us-east-1"
    },
  }
}

########################################
# Create Lambda Functions
########################################

module "lambda_functions" {
  source = "../../modules/lambda"

  lambda_functions = local.lambda_functions
  security_group_ids = [module.security_groups.lambda_vpc_security_group_id]
  subnet_ids         = module.network.private_subnet_ids
  function_name      = "lambda_function_name"
  lambda_package     = "lambda_package.zip"
  eventbridge_schedule_expression = "cron(59 23 ? * SUN *)"
}

