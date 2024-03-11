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

variable "bucket_name" {
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

variable "redis_ami" {
  type        = string
  description = "Name of the AMI for Redis in which cluster need to be created"
  default     = ""
}
variable "redis_name" {
  type        = string
  description = "Name of the Redis Instance"
  default     = ""
}

variable "tupacase_ami" {
  type        = string
  description = "Name of the AMI for Redis in which cluster need to be created"
  default     = ""
}
variable "tupacase_name" {
  type        = string
  description = "Name of the Redis Instance"
  default     = ""
}

variable "mongo_ami" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}

variable "openvpn_ami" {
  type        = string
  description = "Name of the AMI for OpenVPN in which cluster need to be created"
  default     = ""
}
variable "mongo_name" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}
variable "bhost_ami" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}

variable "ansible_name" {
  type        = string
  description = "Name of the AMI for Ansible Server in which cluster need to be created"
  default     = ""
}

variable "ansible_ami" {
  type        = string
  description = "Name of the AMI for Ansible Server in which cluster need to be created"
  default     = ""
}

variable "bhost_name" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}
variable "mongo_arbiter" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}

variable "mongo_arbiter_name" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}
variable "bobones_mongo-replica" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}

variable "bobones_mongo-replica_name" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}

variable "valize_mongo_replica" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}

variable "env" {
  type        = string
  description = "Name of the Env where its been deployed"
  default     = ""
}

variable "elephant_ami" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}

variable "elephant_name" {
  type        = string
  description = "Name of the Mongo Instance"
  default     = ""
}

variable "jenkins_ami" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}

variable "jenkins_name" {
  type        = string
  description = "Name of the Mongo Instance"
  default     = ""
}
variable "glaretrammtt_ami" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}
variable "centralized_vpc_flow_logs_bucket_arn" {
  type        = string
  description = "ARN of the centralized S3 bucket for VPC flow logs"
}

variable "glaretrammtt_name" {
  type        = string
  description = "Name of the Mongo Instance"
  default     = ""
}
variable "registration_ami" {
  type        = string
  description = "Name of the AMI for registrationin which cluster need to be created"
  default     = ""
}

variable "registration_name" {
  type        = string
  description = "Name of the registration Instance"
  default     = ""
}

variable "scheduler_ami" {
  type        = string
  description = "Name of the AMI for scheduler which cluster need to be created"
  default     = ""
}

variable "scheduler_name" {
  type        = string
  description = "Name of the scheduler Instance"
  default     = ""
}
variable "glaretram_ami" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}

variable "glaretram_name" {
  type        = string
  description = "Name of the Mongo Instance"
  default     = ""
}

variable "grynn_postgress_ami" {
  type        = string
  description = "Name of the AMI for Mongo in which cluster need to be created"
  default     = ""
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM cert ARN"
  default     = ""
}
variable "ssl_support_method" {
  type        = string
  description = "SSL Support method"
  default     = ""
}
variable "aliases_dash" {
  type        = string
  description = "SSL Support method"
  default     = ""
}
variable "aliases_mobile" {
  type        = string
  description = "SSL Support method"
  default     = ""
}
variable "grynn_postgress_name" {
  type        = string
  description = "Name of the Mongo Instance"
  default     = ""
}
variable "subnet" {
  type        = string
  description = "List of subnets"
  default     = ""
}

variable "ssl_certificate" {
  type        = string
  description = "SSL Certificate"
  default     = ""
}
variable "vpc" {
  type        = string
  description = "VPC id"
  default     = ""
}

variable "postgres_ver" {
  type        = string
  description = "Postgres Engine version"
  default     = ""
}

variable "postgres_instance_class" {
  type        = string
  description = "Postgres Instance Class"
  default     = ""
}

variable "postgres_snapshot" {
  type        = string
  description = "Postgres Snapshot name"
  default     = ""
}
