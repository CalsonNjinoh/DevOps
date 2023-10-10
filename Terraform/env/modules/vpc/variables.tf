variable "name" {
  type        = string
  description = "Name of environment"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}

variable "cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public Subnets"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private Subnets"
}

variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}
