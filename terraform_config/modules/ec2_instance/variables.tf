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
