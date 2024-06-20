variable "name" {
  type        = string
  description = "name"
  default     = ""
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = ""
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR range"
}

variable "tags" {
  type        = map(string)
  description = "Map of VPC tags"
}

variable "subnet_list" {
  type = list(object({
    name = string
    cidr = string
    type = string
  }))
}

variable "igw_name" {
  type        = string
  description = "Enter igw tag name"
}

variable "public_routetable_name" {
  type        = string
  description = "Enter public_route_table tag name"
}

variable "private_routetable_name" {
  type        = string
  description = "Enter private_route_table tag name"
}

variable "azs" {
  description = "Availability Zone"
  type        = list(string)
  default     = []
}
