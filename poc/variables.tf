variable "vpc_id" {
  description = "VPC ID to create the security group in"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "tags" {
  description = "Tags for the security group"
  type        = map(string)
  default     = {}
}

variable "backup_private_ip" {
  description = "Private IP address for the backup server"
  type        = string
}

variable "redis_private_ip" {
  description = "Private IP address for the Redis server"
  type        = string
}

#########################################
# Conditional creation of security groups
#########################################

variable "create_default_sg" {
  type    = bool
  default = true
}

variable "create_redis_sg" {
  type    = bool
  default = true
}

variable "create_mqtt_sg" {
  type    = bool
  default = true
}

variable "create_elephants_sg" {
  type    = bool
  default = true
}

variable "create_nginx_sg" {
  type    = bool
  default = true
}

variable "create_registration_server_sg" {
  type    = bool
  default = true
}

variable "create_ssh_sg" {
  type    = bool
  default = true
}

variable "create_api_sg" {
  type    = bool
  default = true
}

variable "create_alb_sg" {
  type    = bool
  default = true
}

variable "create_backups_sg" {
  type    = bool
  default = true
}

variable "create_vpn_sg" {
  type    = bool
  default = true
}

variable "create_opensearch_sg" {
  type    = bool
  default = true
}

variable "create_backend_services_sg" {
  type    = bool
  default = true
}

variable "create_lambda_sg" {
  type    = bool
  default = true
}
