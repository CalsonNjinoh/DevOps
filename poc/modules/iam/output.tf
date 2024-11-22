output "ec2_iam_role" {
  description = "EC2 SSM Instance Profile Name"
  value       = aws_iam_instance_profile.this.name
}
