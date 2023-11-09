resource "aws_iam_role" "cross_account_route53_access" {
  name               = "CrossAccountRoute53Access"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::338674575706:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "route53_full_access" {
  role       = aws_iam_role.cross_account_route53_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}
