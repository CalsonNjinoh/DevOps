variable "env" {
  description = "Static Environment names and default tags"
  default = {
    "default" = {
      name = "Default"
      tags = {
        Type        = "Default"
        Environment = "Default"
      }
    }
    "staging" = {
      name = "Staging"
      tags = {
        Type        = "Staging"
        Environment = "Staging"
      }
    }

    "prod" = {
      name = "Production"
      tags = {
        Type        = "Production"
        Environment = "Production"
      }
    }

    "dev" = {
      name = "Development"
      tags = {
        Type        = "Development"
        Environment = "Development"
      }
    }
  }
}

variable "vpcs" {
  type        = map(string)
  description = "VPC IDs"
  default = {
    "default" = "vpc-default-id"
    "prod"    = "vpc-prod-id"
    "dev"     = "vpc-dev-id"
    "staging" = "vpc-staging-id"
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR range"
  default     = "10.197.0.0/16"
}

variable "subnet_list" {
  description = "EKS nodes subnets"
  default = [
    {
      name = "private-subnet-1"
      cidr = "10.197.127.0/24"
      type = "private"
    },
    {
      name = "private-subnet-2"
      cidr = "10.197.128.0/24"
      type = "private"
    },
    {
      name = "public-subnet-1"
      cidr = "10.197.0.0/24"
      type = "public"
    },
    {
      name = "public-subnet-2"
      cidr = "10.197.1.0/24"
      type = "public"
    },
  ]
}

variable "es_subnets" {
  description = "Elastic search subnets"
  type        = list(string)
  default     = ["10.197.123.0/24"]
}

variable "ec2_ssh_key_name" {
  type        = string
  description = "Name of the ssh keypair that will be assigned to EC2 worker nodes"
  default     = "bastion"
}

variable "scaling_configuration" {
  type        = map(number)
  description = "Scaling configurations that need to be passed to auto-scaling group which creates worker nodes"
  default = {
    min_size     = 1
    desired_size = 2
    max_size     = 3
  }
}

variable "instance_type" {
  description = "EKS instance types"
  default     = "t3.medium"
}

variable "es_instance_type" {
  description = "Elastic search instance types"
  default     = "t3.medium.search"
}

variable "region" {
  type        = string
  description = "Name of the region in which cluster need to be created"
  default     = "ca-central-1"
}

variable "ebs_namespace" {
  type        = string
  description = "Namespace in which ebs is created"
  default     = "default"
}

variable "ebs_service_account" {
  type        = string
  description = "Service account name for Secret manager "
  default     = "ebs-csi-controller-sa"
}

variable "secret_manager_namespace" {
  type        = string
  description = "Namespace in which ebs is created"
  default     = "default"
}

variable "secret_manager_service_account" {
  type        = string
  description = "Service account name for Secret manager "
  default     = "csi-secrets-store-provider-aws"
}

variable "secret_manager_role_name" {
  type        = string
  description = "Role Name of the EKS cluster for service account"
  default     = "csi-secrets-store-provider-aws-cluster-role"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "external_dns_role_name" {
  description = "External DNS IAM Role Name"
  type        = string
  default     = "external-dns-role"
}

variable "external_dns_sa_name" {
  description = "External DNS Service Account Name"
  type        = string
  default     = "external-dns-sa"
}

variable "cert_manager_sa_name" {
  description = "Cert Manager Service Account Name"
  type        = string
  default     = "cert-manager-sa"
}

variable "cert_manager_role_name" {
  description = "Cert Manager IAM Role Name"
  type        = string
  default     = "cert-manager-role"
}

variable "cloudwatch_agent_role_name" {
  description = "Cloudwatch agent IAM Role Name"
  type        = string
  default     = "cloudwatch-agent"
}

variable "cloudwatch_agent_sa_name" {
  description = "Cloudwatch agent SA Name"
  type        = string
  default     = "cloudwatch-agent"
}

variable "aws_fluentbit_role_name" {
  description = "AWS Fluent Bit IAM Role Name"
  type        = string
  default     = "aws-fluentbit"
}

variable "aws_fluentbit_sa_name" {
  description = "AWS Fluent Bit SA Name"
  type        = string
  default     = "aws-fluentbit"
}

variable "aws_key" {
  description = "AWS KEY"
  type        = string
  default     = "default-aws-key"
}

variable "aws_secret" {
  description = "AWS Secret"
  type        = string
  default     = "default-aws-secret"
}

variable "zone_id" {
  description = "The Zone ID to deploy to"
  default     = "default-zone-id"
}

variable "root_domain" {
  description = "The root domain"
  default     = "default-root-domain"
}

variable "aws_auth_users" {
  description = "users"
  default     = []
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
  default     = "development"  
}