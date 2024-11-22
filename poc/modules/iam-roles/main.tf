########################################
# Create IAM Instance Profile
########################################

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  count = var.create_ssm_role ? 1 : 0
  name  = "${aws_iam_role.ssm_role[0].name}_profile"
  role  = aws_iam_role.ssm_role[0].name
}

resource "aws_iam_instance_profile" "secrets_instance_profile" {
  count = var.create_backend_role ? 1 : 0
  name  = "${aws_iam_role.backend_role[0].name}_profile"
  role  = aws_iam_role.backend_role[0].name
}

resource "aws_iam_instance_profile" "backup_instance_profile" {
  count = var.create_backup_role ? 1 : 0
  name  = "${aws_iam_role.backup_role[0].name}_profile"
  role  = aws_iam_role.backup_role[0].name
}

########################################
# Session Manager Role
########################################

resource "aws_iam_role" "ssm_role" {
  count = var.create_ssm_role ? 1 : 0
  name  = "ssm_role_${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ]
  })
}

resource "aws_iam_role" "backend_role" {
  count = var.create_backend_role ? 1 : 0
  name  = "backend_role_${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ]
  })
}

resource "aws_iam_role" "backup_role" {
  count = var.create_backup_role ? 1 : 0
  name  = "backup_role_${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ]
  })
}

############################################
# Lambda Function Role for reporting account
###########################################

resource "aws_iam_role" "lambda_exec" {
  count              = var.create_lambda_exec_role ? 1 : 0
  name               = "lambda_exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

###############################################################
# Policy Attachments for reporting account Lambda execution role
###############################################################

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attachment" {
  count      = var.create_lambda_exec_role && length(var.policies_for_lambda_exec_role) > 0 ? length(var.policies_for_lambda_exec_role) : 0
  role       = aws_iam_role.lambda_exec[0].name
  policy_arn = var.policies_for_lambda_exec_role[count.index].policy_arn
}


########################################
# Create IAM Role in Production Account
########################################

resource "aws_iam_role" "production_role" {
  count = var.create_production_role ? 1 : 0
  name  = "production_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::831286133761:role/lambda_exec"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
########################################
# Policy Attachment for Production Role
########################################

resource "aws_iam_role_policy_attachment" "production_policy_attachment" {
  count      = var.create_production_role && length(var.policies_for_production_role) > 0 ? length(var.policies_for_production_role) : 0
  role       = aws_iam_role.production_role[0].name
  policy_arn = var.policies_for_production_role[count.index].policy_arn
}



########################################
# Policy Attachment for Session Manager
########################################

resource "aws_iam_role_policy_attachment" "ssm_managed_policy_attachment" {
  count      = var.create_ssm_role ? 1 : 0
  role       = aws_iam_role.ssm_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "ec2_role_for_ssm_policy_attachment" {
  count      = var.create_ssm_role ? 1 : 0
  role       = aws_iam_role.ssm_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  count      = length(var.ssm_role_policies)
  role       = aws_iam_role.ssm_role[0].name
  policy_arn = var.ssm_role_policies[count.index].policy_arn
}

resource "aws_iam_role_policy_attachment" "ec2_role_for_cloudwatch_agent_attachment" {
  count      = var.create_ssm_role ? 1 : 0
  role       = aws_iam_role.ssm_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "backend_ssm_managed_policy_attachment" {
  count      = var.create_backend_role ? 1 : 0
  role       = aws_iam_role.backend_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "backend_ec2_role_for_ssm_policy_attachment" {
  count      = var.create_backend_role ? 1 : 0
  role       = aws_iam_role.backend_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "backend_ec2_role_for_cloudwatch_agent_policy_attachment" {
  count      = var.create_backend_role ? 1 : 0
  role       = aws_iam_role.backend_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "backend_policy_attachment" {
  count      = length(var.policies_for_backend_role)
  role       = aws_iam_role.backend_role[0].name
  policy_arn = var.policies_for_backend_role[count.index].policy_arn
}

resource "aws_iam_role_policy_attachment" "backup_policy_attachment" {
  count      = length(var.backup_role_policies)
  role       = aws_iam_role.backup_role[0].name
  policy_arn = var.backup_role_policies[count.index].policy_arn
}

resource "aws_iam_role_policy_attachment" "backup_ec2_role_for_ssm_policy_attachment" {
  count      = var.create_backup_role ? 1 : 0
  role       = aws_iam_role.backup_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "backup_ec2_role_for_cloudwatch_agent_policy_attachment" {
  count      = var.create_backup_role ? 1 : 0
  role       = aws_iam_role.backup_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "backup_ssm_managed_policy_attachment" {
  count      = var.create_backup_role ? 1 : 0
  role       = aws_iam_role.backup_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


##########################################################
# IAM Role for VPC flowlogs destination to CloudWatch logs
##########################################################

/*resource "aws_iam_role" "vpc_flow_logs_role" {
  count = var.create_vpc_flow_logs_role ? 1 : 0
  name  = "vpcFlowLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs_policy_attachment" {
  count      = var.create_vpc_flow_logs_role ? length(var.policies_for_vpc_flow_logs_role) : 0
  role       = aws_iam_role.vpc_flow_logs_role[0].name
  policy_arn = var.policies_for_vpc_flow_logs_role[count.index].policy_arn
}*/


resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "vpc-flow-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "vpc_flow_logs" {
  role       = aws_iam_role.vpc_flow_logs_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess" 
}


####################################################################################
# create IAM role for eventbridge to invoke lambda for scheduled events vpc flow logs
####################################################################################

resource "aws_iam_role" "eventbridge_invoke_lambda" {
  name = "eventbridge_invoke_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}
