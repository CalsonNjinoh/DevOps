resource "aws_iam_role" "ebs_lifecycle_role" {
  name = "ebs_lifecycle_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dlm.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy" "ebs_lifecycle_role_policy" {
  name   = "ebs_lifecycle_role_policy"
  role   = aws_iam_role.ebs_lifecycle_role.id
  policy = data.aws_iam_policy_document.ebs_lifecycle_policy.json
}
data "aws_iam_policy_document" "ebs_lifecycle_policy" {
  statement {
    actions   = ["ec2:CreateSnapshot", "ec2:DeleteSnapshot", "ec2:DescribeVolumes", "ec2:DescribeSnapshots"]
    resources = ["*"]
  }
}
