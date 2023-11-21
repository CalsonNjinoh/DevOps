variable "asg_name" {
  description = "Name of the Auto Scaling Group"
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
}

variable "desired_capacity" {
  description = "Desired capacity of the ASG"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ASG"
  type        = list(string)
}

variable "launch_template_name" {
  description = "Name of the launch template"
}

variable "launch_template_description" {
  description = "Description of the launch template"
}

variable "image_id" {
  description = "AMI ID for the instances"
}

variable "instance_type" {
  description = "Instance type for the instances"
}

variable "iam_role_name" {
  description = "Name of the IAM role for instances"
}

variable "iam_role_description" {
  description = "Description of the IAM role for instances"
}

variable "security_group_id" {
  description = "ID of the security group for instances"
}

variable "availability_zone" {
  description = "Availability zone for instances"
}
variable "vpc_id" {
  description = "VPC ID where the load balancer will be deployed"
}
variable "alb_subnets" {
  description = "List of subnet IDs for the Application Load Balancer"
  type        = list(string)
}
variable "alb_security_groups" {
  description = "List of security group IDs for the Application Load Balancer"
  type        = list(string)
}
variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
}
variable "create_alb_security_group" {
  description = "Whether to create a security group for the ALB"
  type        = bool
  default     = false
}
