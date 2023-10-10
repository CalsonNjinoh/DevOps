variable "subnets" {
  description = "Subnet IDs to launch instance in"
  default     = ""
}

variable "instance_ami" {
  description = "Instance AMI to create from"
  default     = ""
}

variable "instance_type" {
  description = "Replica EC2 Instance Type"
  default     = ""
}

variable "num_of_elephants" {
  description = "Number of elephants to create"
  default     = ""
}

variable "secure_ssh_sg" {
  description = "Secure SSH Security Group"
  default     = ""
}

variable "ssh_key_name" {
  description = "SSH Key Name"
  default     = ""
}

variable "root_volume_size" {
  description = "Root Volume Size"
  default     = ""
}

variable "block_volume_size" {
  description = "Block Volume Size"
  default     = ""
}

variable "volume_type" {
  description = "Volume type"
  default     = ""
}

variable "device_name" {
  description = "Device path"
  default     = ""
}

variable "tags" {
  description = "Tags"
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID"
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR range"
  default     = ""
}

variable "instance_profile" {
  description = "EC2 IAM Instance Profile"
  default     = ""
}

variable "ingress_ports" {
  description = "List of Ingress ports"
  type        = list(Number)
  default     = []
}
variable "egress_ports" {
  description = "List of Ingress ports"
  type        = list(Number)
  default     = []
}

# variable "domain_name" {
#   description = "DNS Domain Name"
#   default     = ""
# }
