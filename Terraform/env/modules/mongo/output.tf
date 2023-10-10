variable "subnets" {
  description = "Subnet IDs to launch instance in"
  default     = ""
}

variable "instance_ami" {
  description = "Instance AMI to create from"
  default     = ""
}

variable "replica_instance_type" {
  description = "Replica EC2 Instance Type"
  default     = ""
}

variable "arbiter_instance_type" {
  description = "Arbiter EC2 Instance Type"
  default     = ""
}

variable "num_of_replicas" {
  description = "Number of replicas to create"
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
variable "root_volume_size" {
  description = "Root Volume Size"
  default     = ""
}

variable "volume_type" {
  description = "Volume type"
  default     = ""
}

variable "instance_profile" {
  description = "EC2 IAM Instance Profile"
  default     = ""
}

variable "mongo_ebs_block_device" {
  description = "List of Ebs Block Devices"
  type        = list(map(string)) 
  default     = []
}
variable "arbiter_ebs_block_device" {
  description = "List of Ebs Block Devices"
  type        = list(map(string)) 
  default     = []
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
