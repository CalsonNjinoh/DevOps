locals {
  role_name          = "EC2-SSM-${var.name}"
  instance_role_name = "EC2-SSM-Instance-${var.name}"
  role_description   = "EC2 SSM Role"
}

########################################
# EC2 SSM Role
########################################

resource "aws_iam_role" "this" {
  name               = local.role_name
  description        = local.role_description
  assume_role_policy = <<EOF
	{
		"Version": "2012-10-17",
		"Statement": {
			"Effect": "Allow",
			"Principal": {
				"Service": "ec2.amazonaws.com"
			},
			"Action": "sts:AssumeRole"
		}
	}
	EOF

  tags = var.tags
}

resource "aws_iam_instance_profile" "this" {
  name = local.instance_role_name
  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
