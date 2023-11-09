########################################
# Create IAM Instance Profile
########################################
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  count = var.create_ssm_role ? 1 : 0
  name  = "${aws_iam_role.ssm_role[0].name}_profile"
  role  = aws_iam_role.ssm_role[0].name
}
########################################
# Session Manager Role
########################################

resource "aws_iam_role" "ssm_role" {
  count = var.create_ssm_role ? 1 : 0
  name = "ssm_role"
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
########################################
# Policy Attachment for Session Manager
########################################

resource "aws_iam_role_policy_attachment" "ssm_managed_policy_attachment" {
  count = var.create_ssm_role ? 1 : 0
  role       = aws_iam_role.ssm_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "ec2_role_for_ssm_policy_attachment" {
  count = var.create_ssm_role ? 1 : 0
  role       = aws_iam_role.ssm_role[0].name
  policy_arn = "arn:aws:iam::762372983622:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM"
}
