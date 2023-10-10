variable "region" {
  type        = string
  description = "Name of the region in which cluster need to be created"
  default     = "us-east-2"
}

variable "name" {
  type        = string
  description = "Name of environment"
  default     = "name"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = []
}

variable "cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "0.0.0.0/0"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public Subnets"
  default     = []
}

variable "private_subnets" {
  type        = list(string)
  description = "Private Subnets"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}

variable "key_path" {
  type        = string
  description = "Path to SSH public key"
  default     = ""
}
