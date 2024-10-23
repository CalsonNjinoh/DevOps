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
  description = "Whether to create the Default security group"
  type        = bool
  default     = true
}

variable "create_redis_sg" {
  description = "Whether to create the Redis security group"
  type        = bool
  default     = false
}

variable "create_mqtt_sg" {
  description = "Whether to create the MQTT security group"
  type        = bool
  default     = false
}

variable "create_elephants_sg" {
  description = "Whether to create the Elephants security group"
  type        = bool
  default     = false
}

variable "create_nginx_sg" {
  description = "Whether to create the Nginx security group"
  type        = bool
  default     = false
}

variable "create_registration_server_sg" {
  description = "Whether to create the Registration Server security group"
  type        = bool
  default     = false
}

variable "create_ssh_sg" {
  description = "Whether to create the SSH security group"
  type        = bool
  default     = false
}

variable "create_api_sg" {
  description = "Whether to create the API security group"
  type        = bool
  default     = false
}

variable "create_alb_sg" {
  description = "Whether to create the ALB security group"
  type        = bool
  default     = false
}

variable "create_backups_sg" {
  description = "Whether to create the Backups security group"
  type        = bool
  default     = false
}

variable "create_vpn_sg" {
  description = "Whether to create the VPN security group"
  type        = bool
  default     = false
}

variable "create_opensearch_sg" {
  description = "Whether to create the OpenSearch security group"
  type        = bool
  default     = false
}

variable "create_backend_services_sg" {
  description = "Whether to create the Backend Services security group"
  type        = bool
  default     = false
}

variable "create_lambda_sg" {
  description = "Whether to create the Lambda VPC security group"
  type        = bool
  default     = true
}
