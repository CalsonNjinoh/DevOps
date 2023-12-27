variable "domain_name" {
  description = "Name of the OpenSearch domain."
  type        = string
}
variable "elasticsearch_version" {
  description = "Version of OpenSearch to deploy."
  type        = string
}
variable "instance_type" {
  description = "Instance type of the OpenSearch cluster nodes."
  type        = string
}
variable "instance_count" {
  description = "Number of instances in the OpenSearch cluster."
  type        = number
}
variable "ebs_enabled" {
  description = "Whether EBS volumes are attached to data nodes in the OpenSearch domain."
  type        = bool
}
variable "volume_size" {
  description = "The size of the EBS volumes."
  type        = number
}
variable "volume_type" {
  description = "The type of EBS volumes."
  type        = string
}
variable "security_group_ids" {
  description = "List of security group IDs to apply to the OpenSearch domain."
  type        = list(string)
  
}   
variable "private_subnet_ids" {
  description = "List of subnet IDs to deploy the OpenSearch domain into."
  type        = string
}
