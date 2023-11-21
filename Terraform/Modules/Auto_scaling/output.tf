output "alb_security_group_id" {
  value = var.create_alb_security_group ? aws_security_group.alb_sg[0].id : ""
  description = "ID of the ALB security group"
}
