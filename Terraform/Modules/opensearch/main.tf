# Description: This file contains the terraform configuration to create an OpenSearch cluster.
resource "aws_elasticsearch_domain" "devtest" {
  domain_name           = var.domain_name
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    instance_type  = var.instance_type
    instance_count = var.instance_count
  }
  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  vpc_options {
    subnet_ids         = [var.private_subnet_ids]
    security_group_ids = var.security_group_ids
}
}
