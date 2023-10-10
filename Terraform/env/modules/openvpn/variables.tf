variable "subnet" {
  description = "Subnet ID to launch instance in"
  default     = ""
}

variable "instance_type" {
  description = "EC2 Instance Type"
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

variable "instance_profile" {
	description = "EC2 IAM Instance Profile"
	default = ""
}

variable "route_53_zone_id" {
	description = "Route 53 Domain"
	default = ""
}

variable "domain_name" {
	description = "DNS Domain Name"
	default = ""
}

variable "openvpn_ingress_ports" {
  description = "List of Ingress ports"
  type        = list(Number)
  default     = []
}

variable "ssh_ingress_ports" {
  description = "List of Ingress ports"
  type        = list(Number)
  default     = []
}

variable "egress_ports" {
  description = "List of Ingress ports"
  type        = list(Number)
  default     = []
}
