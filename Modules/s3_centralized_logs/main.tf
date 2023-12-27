resource "aws_s3_bucket" "centralized_vpc_flow_logs" {
  bucket        = var.bucket_name
  force_destroy = true
}
resource "aws_s3_bucket_policy" "centralized_vpc_flow_logs_policy" {
  bucket = aws_s3_bucket.centralized_vpc_flow_logs.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSLogDeliveryWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::dev-centralized-vpc-flow-logs-bucket/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "AWSLogDeliveryCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::dev-centralized-vpc-flow-logs-bucket"
        },
        {
            "Sid": "DenyUnencryptedTraffic",
            "Effect": "Deny",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::dev-centralized-vpc-flow-logs-bucket",
                "arn:aws:s3:::dev-centralized-vpc-flow-logs-bucket/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        },
        {
            "Sid": "AWSLogDeliveryWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::dev-centralized-vpc-flow-logs-bucket/AWSLogs/762372983622/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control",
                    "aws:SourceAccount": "762372983622"
                },
                "ArnLike": {
                    "aws:SourceArn": "arn:aws:logs:ca-central-1:762372983622:*"
                }
            }
        },
        {
            "Sid": "AWSLogDeliveryAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::dev-centralized-vpc-flow-logs-bucket",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": "762372983622"
                },
                "ArnLike": {
                    "aws:SourceArn": "arn:aws:logs:ca-central-1:762372983622:*"
                }
            }
        }
    ]
}
)
}
