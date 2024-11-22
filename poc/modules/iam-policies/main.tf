resource "aws_iam_policy" "secrets_policy" {
  count       = var.create_secrets_policy ? 1 : 0
  name        = "backend_secrets_read_${var.env}"
  description = "Allow reading backend secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect = "Allow"
        Resource = [
          var.secrets_arn,
          var.firebase_arn
        ]
      },
      {
        "Effect" = "Allow"
        "Action" = [
          "kms:Decrypt"
        ]
        "Resource" = [
          var.secrets_encryption_key_arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "atlas_policy" {
  count = var.create_atlas_policy ? 1 : 0
  name  = "atlas_kms_policy_${var.env}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : [
          var.atlas_kms_key_arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "backup_write_policy" {
  count       = var.create_backup_policy ? 1 : 0
  name        = "backup_write_policy_${var.env}"
  description = "Allow writing to backup bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          "${var.backup_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "chime_policy" {
  count = var.create_chime_policy ? 1 : 0
  name  = "chime_policy_${var.env}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "chime:CreateMeeting",
          "chime:CreateMeetingWithAttendees",
          "chime:DeleteMeeting",
          "chime:GetMeeting",
          "chime:ListMeetings",
          "chime:CreateAttendee",
          "chime:BatchCreateAttendee",
          "chime:DeleteAttendee",
          "chime:GetAttendee",
          "chime:ListAttendees",
          "chime:ListAttendeeTags",
          "chime:ListMeetingTags",
          "chime:ListTagsForResource",
          "chime:TagAttendee",
          "chime:TagMeeting",
          "chime:TagResource",
          "chime:UntagAttendee",
          "chime:UntagMeeting",
          "chime:UntagResource",
          "chime:StartMeetingTranscription",
          "chime:StopMeetingTranscription",
          "chime:CreateMediaCapturePipeline",
          "chime:CreateMediaConcatenationPipeline",
          "chime:CreateMediaLiveConnectorPipeline",
          "chime:DeleteMediaCapturePipeline",
          "chime:DeleteMediaPipeline",
          "chime:GetMediaCapturePipeline",
          "chime:GetMediaPipeline",
          "chime:ListMediaCapturePipelines",
          "chime:ListMediaPipelines"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "workflow_logs_policy" {
  count = var.create_workflow_logs_policy ? 1 : 0
  name  = "workflow_logging_role_${var.env}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ],
        "Resource" : [
          "arn:aws:logs:ca-central-1:427366260079:log-group:${var.workflow_logs_arn}",
          "arn:aws:logs:ca-central-1:427366260079:log-group:${var.workflow_logs_arn}:log-stream:*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_log" {
  count = var.create_cloudwatch_log_policy ? 1 : 0
  name  = "cloudwatch_agent_policy_${var.env}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "sts:AssumeRole"
      ],
      "Resource" : [
        "arn:aws:iam::980766525411:role/CloudwatchAgentRole"
      ]
    }]
  })
}

resource "aws_iam_policy" "cloudwatch_agent_policy" {
  count = var.create_cloudwatch_agent_policy ? 1 : 0
  name  = "cloudwatch_agent_policy_${var.env}"

  policy = jsonencode({
    "Statement" : [{
      "Action" : [
        "sts:AssumeRole"
      ],
      "Effect" : "Allow",
      "Resource" : [
        var.cloudwatch_agent_role
      ]
    }],
    "Version" : "2012-10-17"
  })

}


############################################
## IAM POLICIES FOR LAMBDA
############################################

resource "aws_iam_policy" "s3_data_uploads_us" {
  count       = var.create_s3_data_uploads_us_policy ? 1 : 0
  name        = "S3DataUploads_${var.env}"
  description = "Policy for S3 data uploads in US"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "VisualEditor0",
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::data-exports_${var.env}/*",
          "arn:aws:s3:::aetonix-reports-production_${var.env}/*",
          "arn:aws:s3:::data-exports-usa",
          "arn:aws:s3:::aetonix-reports-production_${var.env}"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "systems_manager_get_parameters" {
  count       = var.create_systems_manager_get_parameters_policy ? 1 : 0
  name        = "SystemsManagerGetParameters"
  description = "Policy for getting parameters from Systems Manager"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "VisualEditor0",
        Effect = "Allow",
        Action = [
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        Resource = "arn:aws:ssm:*:427174714230:parameter/*"
      },
      {
        Sid = "VisualEditor1",
        Effect = "Allow",
        Action = "ssm:DescribeParameters",
        Resource = "*"
      }
    ]
  })
}


##############################################################
 # Policy to allow Lambda to assume role in destination account
##############################################################

resource "aws_iam_policy" "assume_cross_account_role_policy" {
  count       = var.create_assume_cross_account_role_policy ? 1 : 0
  name        = "AssumeCrossAccountRolePolicy"
  description = "Policy to allow Lambda to assume role in destination account"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = "arn:aws:iam::973334513903:role/production_role"
      }
    ]
  })
}

############################################################
## IAM POLICIES FOR VPC FLOW LOGS - DESTINATION CLOUDWATCH LOGS
############################################################

resource "aws_iam_policy" "vpc_flow_logs_policy" {
  count = var.create_vpc_flow_logs_policy ? 1 : 0
  name   = "vpcFlowLogsPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
