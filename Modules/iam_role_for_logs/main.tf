resource "aws_iam_role" "vpc_flow_log_role" {
  name               = "VPCFlowLogRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Principal = { Service = "vpc-flow-logs.amazonaws.com" },
        Effect    = "Allow",
        Sid       = ""
      }
    ]
  })
}
resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  name = "VPCFlowLogPolicy"
  role = aws_iam_role.vpc_flow_log_role.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = "arn:aws:s3:::${var.bucket_name}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
