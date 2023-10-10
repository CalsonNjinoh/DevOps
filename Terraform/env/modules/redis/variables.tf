variable "subnet" {
  description = "Subnet ID to launch instance in"
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

variable "secure_ssh_sg" {
  description = "Secure SSH Security Group"
  default     = ""
}

variable "ssh_key_name" {
  description = "SSH Key Name"
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
variable "ebs_block_device" {
  description = "List of Ebs Block Devices"
  type        = list(map(string)) 
  default     = []
}
variable "instance_profile" {
  description = "EC2 IAM Instance Profile"
  default     = ""
}

variable "root_volume_size" {
  description = "Root Volume Size"
  default     = ""
}

variable "volume_type" {
  description = "Volume type"
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
# variable "route_53_zone_id" {
#   description = "Route 53 Domain"
#   default     = ""
# }

# variable "domain_name" {
#   description = "DNS Domain Name"
#   default     = ""
# }
