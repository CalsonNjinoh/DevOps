variable "ami_id" {
  description = "The AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to deploy the instance in"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the instance"
  type        = string
}
variable "vpc_security_group_ids" {
  description = "List of security group IDs to attach to the EC2 instance"
  type        = list(string)
  default     = []
}
variable "iam_instance_profile_name" {
  type = string
  description = "The name of the IAM instance profile to attaach to the EC2 instance"
  default = ""
}

variable "alarm_action_arn" {
  description = "ARN of the alarm action (e.g., SNS Topic ARN)"
  type        = string
}

variable "ok_action_arn" {
  description = "ARN to trigger when the alarm state returns to OK"
  type        = string
  default     = ""
}

variable "insufficient_data_action_arn" {
  description = "ARN to trigger when the alarm state is insufficient data"
  type        = string
  default     = ""
}
