provider "aws" {
  region = var.region
}

# terraform {
#   backend "local" {
#     path = "terraform.tfstate"
#   }
# }
terraform {
  backend "s3" {
    bucket = "stage-state-file"
    key    = "terraform.tfstate"
    region = "ca-central-1"
    encrypt = true
  }
}

resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "${var.name} TF SSH Key"
  public_key = file("~/.ssh/stage_key.pub")
}

########################################
# Create VPC, Subnets, Route Tables
########################################
module "network" {
  source                                = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/vpc?ref=TF_module"
  name                                  = var.name

  azs                                   = var.azs
  cidr                                  = var.cidr

  public_subnets                        = var.public_subnets
  private_subnets                       = var.private_subnets
  tags                                  = var.tags
  centralized_vpc_flow_logs_bucket_arn  = var.centralized_vpc_flow_logs_bucket_arn
}

########################################
# Create required AMIs
########################################
module "iam" {
  source = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/iam?ref=TF_module"
  tags   = var.tags
  name   = var.name
}
module "iam_ssm" {
  source = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/iam_roles?ref=TF_module"
  create_ssm_role = true
  OU = "973334513903"
}

########################################
# Create VPN EC2
########################################
module "openvpn" {
  source           = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/openvpn?ref=TF_module"
  subnet           = module.network.public_subnet_ids[0]
  ami              = var.openvpn_ami
  ssh_key_name     = aws_key_pair.ssh_key_pair.key_name
  instance_type    = "t2.micro"
  vpc_cidr         = var.cidr
  vpc_id           = module.network.vpc_id
  tags             = var.tags
  instance_profile = module.iam_ssm.ssm_instance_profile_name
  #route_53_zone_id = data.aws_route53_zone.aetonixxyz.zone_id
  domain_name      = "vpn.staging.aetonix.xyz"
}

# module "bastionhost" {
#   source           = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/bastionhost?ref=TF_module"
#   subnet           = module.network.public_subnet_ids[1]
#   instance_ami     = var.bhost_ami
#   instance_name    = var.bhost_name
#   instance_type    = "t2.micro"
#   ssh_key_name     = aws_key_pair.ssh_key_pair.key_name
#   #secure_ssh_sg    = module.openvpn.ssh_sg.id
#   vpc_id           = module.network.vpc_id
#   tags             = var.tags
#   #instance_profile = module.iam.ec2_iam_role
#   instance_profile = module.iam_ssm.ssm_instance_profile_name
#   root_volume_size = 100
#   volume_type      = "gp2"
#   # ebs_block_devices = [
#   #   {
#   #     # Data
#   #     device_name           = "/dev/xvdba"
#   #     volume_size           = 40
#   #     volume_type           = "gp2"
#   #   }
#   # ]
#   ingress_ports    = [
#     {
#       from_port   = 6169
#       to_port     = 6169
#       protocol    = "tcp"
#       cidr_blocks = [var.cidr]
#       security_group_id = []
#     },
#     {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#       security_group_id = []
#     }
#   ]
#   egress_ports     = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "tcp"
#       cidr_blocks = [var.cidr]
#     },
#     {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   ]
# }

module "ansible" {
  source           = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/ansible?ref=TF_module"
  subnet           = module.network.private_subnet_ids[1]
  instance_ami     = var.ansible_ami
  instance_name    = var.ansible_name
  instance_type    = "t3.medium"
  ssh_key_name     = aws_key_pair.ssh_key_pair.key_name
  vpc_cidr         = var.cidr
  #secure_ssh_sg    = module.openvpn.ssh_sg.id
  vpc_id           = module.network.vpc_id
  tags             = var.tags
  instance_profile = module.iam_ssm.ssm_instance_profile_name
  root_volume_size = 20
  volume_type      = "gp2"
  ingress_ports    = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      #security_group_id = []
      security_group_id = [module.openvpn.ssh_sg]
    }
  ]
  egress_ports     = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    }
  ]
}
# ########################################
# # Create Redis Instance
# ########################################

module "vasco_redis" {
  source           = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/redis?ref=TF_module"
  subnet           = module.network.private_subnet_ids[1]
  instance_ami     = var.redis_ami
  instance_name    = var.redis_name
  instance_type    = "t3.medium"
  ssh_key_name     = aws_key_pair.ssh_key_pair.key_name
  vpc_cidr         = var.cidr
  #secure_ssh_sg    = module.openvpn.ssh_sg.id
  vpc_id           = module.network.vpc_id
  tags             = var.tags
  instance_profile = module.iam_ssm.ssm_instance_profile_name
  root_volume_size = 20
  volume_type      = "gp2"
  ingress_ports    = [
    {
      from_port   = 6169
      to_port     = 6169
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      security_group_id = []
    },
    {
      from_port   = 6168
      to_port     = 6168
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      security_group_id = []
    },
    {
      from_port   = 6168
      to_port     = 6168
      protocol    = "tcp"
      cidr_blocks = ["163.35.0.0/16"]
      security_group_id = []
    },
    {
      from_port   = 6168
      to_port     = 6168
      protocol    = "tcp"
      cidr_blocks = ["163.36.0.0/24"]
      security_group_id = []
    },
    {
      from_port   = 6169
      to_port     = 6169
      protocol    = "tcp"
      cidr_blocks = ["163.35.0.0/16"]
      security_group_id = []
    },
    {
      from_port   = 6169
      to_port     = 6169
      protocol    = "tcp"
      cidr_blocks = ["163.36.0.0/24"]
      security_group_id = []
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      #security_group_id = []
      security_group_id = [module.ansible.ansible_sg]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      #security_group_id = []
      security_group_id = [module.openvpn.ssh_sg]
    }
  ]
  egress_ports     = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    }
  ]
}

module "postgress" {
  source                 = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/rds?ref=TF_module"
  db_instance_identifier = "my-rds-identifies"
  db_username            = "myuser"
  db_password            = "mypassword"
  engine_version         = var.postgres_ver
  instance_class         = var.postgres_instance_class
  snapshot_name          = var.postgres_snapshot
  subnets                = [module.network.private_subnet_ids[0], module.network.private_subnet_ids[1]]
  allocated_storage      = 50
  vpc_id                 = module.network.vpc_id
  tags                   = var.tags
  ingress_ports    = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      #security_group_id = []
      security_group_id = [module.ansible.ansible_sg]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      #security_group_id = []
      security_group_id = [module.openvpn.ssh_sg]
    }
  ]
}


module "mongo_sg" {
  source = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/security_group?ref=TF_module"
  name   = "mongo-sg"
  description = "Security group for Mongo"
  vpc_id = module.network.vpc_id
  ingress_rules = [
    {
      description       = "HTTP"
      from_port         = 7616
      to_port           = 7616
      protocol          = "tcp"
      cidr_blocks       = [var.cidr]
      security_group_id = []     
    },
    {
      description       = "SSH"
      from_port         = 22
      to_port           = 22
      protocol          = "tcp"
      cidr_blocks       = []
      security_group_id = [module.ansible.ansible_sg]
    },
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = []
      security_group_id = [module.openvpn.ssh_sg]
    }
  ]
}
# # #######################################
# # #Create Mongo Instances
# # #######################################

module "mongo" {
  source                = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/mongo?ref=TF_module"
  subnets               = module.network.private_subnet_ids[0]
  instance_ami          = var.mongo_ami
  instance_name         = var.mongo_name
  replica_instance_type = "t3.medium"
  ssh_key_name          = aws_key_pair.ssh_key_pair.key_name
  vpc_cidr              = var.cidr
  num_of_replicas       = 1
  #secure_ssh_sg         = module.openvpn.ssh_sg.id
  vpc_id                = module.network.vpc_id
  tags                  = var.tags
  instance_profile      = module.iam_ssm.ssm_instance_profile_name
  root_volume_size      = 20
  volume_type           = "gp2"
  security_group_id     = module.mongo_sg.security_group_id
}

module "mongo_secondary" {
  source                = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/mongo?ref=TF_module"
  subnets               = module.network.private_subnet_ids[0]
  instance_ami          = var.mongo_ami
  instance_name         = "Sassee-Mongo-Secondary"
  replica_instance_type = "t3.medium"
  ssh_key_name          = aws_key_pair.ssh_key_pair.key_name
  vpc_cidr              = var.cidr
  num_of_replicas       = 1
  #secure_ssh_sg         = module.openvpn.ssh_sg.id
  vpc_id                = module.network.vpc_id
  tags                  = var.tags
  instance_profile      = module.iam_ssm.ssm_instance_profile_name
  root_volume_size      = 20
  volume_type           = "gp2"
  security_group_id     = module.mongo_sg.security_group_id
}
module "mongo_second" {
  source                = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/mongo?ref=TF_module"
  subnets               = module.network.private_subnet_ids[0]
  instance_ami          = var.mongo_ami
  instance_name         = "Bumola-Mongo-Secondary"
  replica_instance_type = "t3.medium"
  ssh_key_name          = aws_key_pair.ssh_key_pair.key_name
  vpc_cidr              = var.cidr
  num_of_replicas       = 1
  #secure_ssh_sg         = module.openvpn.ssh_sg.id
  vpc_id                = module.network.vpc_id
  tags                  = var.tags
  instance_profile      = module.iam_ssm.ssm_instance_profile_name
  root_volume_size      = 20
  volume_type           = "gp2"
  security_group_id     = module.mongo_sg.security_group_id
}

module "mongo_arbiter" {
  source                = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/mongo_arbiter?ref=TF_module"
  subnet                = module.network.private_subnet_ids[1]
  instance_ami          = var.mongo_arbiter
  instance_name         = var.mongo_arbiter_name
  instance_type         = "t3.micro"
  ssh_key_name          = aws_key_pair.ssh_key_pair.key_name
  vpc_cidr              = var.cidr
  #secure_ssh_sg         = module.openvpn.ssh_sg.id
  vpc_id                = module.network.vpc_id
  tags                  = var.tags
  instance_profile      = module.iam_ssm.ssm_instance_profile_name
  root_volume_size      = 20
  volume_type           = "gp2"
  security_group_id     = module.mongo_sg.security_group_id
}

# # # ########################################
# # # # Create pruvia Backups
# # # ########################################

module "pruvia_backups" {
  source           = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/redis?ref=TF_module"
  subnet           = module.network.private_subnet_ids[1]
  instance_ami     = var.redis_ami
  instance_name    = "Pruvia-Backups-Logger-Listener"
  instance_type    = "t3.medium"
  ssh_key_name     = aws_key_pair.ssh_key_pair.key_name
  vpc_cidr         = var.cidr
  #secure_ssh_sg    = module.openvpn.ssh_sg.id
  vpc_id           = module.network.vpc_id
  tags             = var.tags
  instance_profile = module.iam_ssm.ssm_instance_profile_name
  root_volume_size = 20
  volume_type      = "gp2"
  # ebs_block_devices = [
  #   {
  #     # Data
  #     device_name           = "/dev/xvdba"
  #     volume_size           = 40
  #     volume_type           = "gp2"
  #   }
  # ]
  ingress_ports    = [
    {
      from_port   = 6169
      to_port     = 6169
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      security_group_id = []
    },
    {
      from_port   = 6168
      to_port     = 6168
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      security_group_id = []
    },
    {
      from_port   = 6168
      to_port     = 6168
      protocol    = "tcp"
      cidr_blocks = ["163.35.0.0/16"]
      security_group_id = []
    },
    {
      from_port   = 6168
      to_port     = 6168
      protocol    = "tcp"
      cidr_blocks = ["163.36.0.0/24"]
      security_group_id = []
    },
    {
      from_port   = 6169
      to_port     = 6169
      protocol    = "tcp"
      cidr_blocks = ["163.35.0.0/16"]
      security_group_id = []
    },
    {
      from_port   = 6169
      to_port     = 6169
      protocol    = "tcp"
      cidr_blocks = ["163.36.0.0/24"]
      security_group_id = []
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = []
      #security_group_id = []
      security_group_id = [module.ansible.ansible_sg]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = []
      #security_group_id = []
      security_group_id = [module.openvpn.ssh_sg]
    }
  ]
  egress_ports     = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    }
  ]
}

module "prod_exports" {
  source           = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/prod_exports?ref=TF_module"
  subnet           = module.network.private_subnet_ids[1]
  instance_ami     = var.tupacase_ami
  instance_name    = "Production-Exports"
  instance_type    = "t3.medium"
  ssh_key_name     = aws_key_pair.ssh_key_pair.key_name
  vpc_cidr         = var.cidr
  #secure_ssh_sg    = module.openvpn.ssh_sg.id
  vpc_id           = module.network.vpc_id
  tags             = var.tags
  instance_profile = module.iam_ssm.ssm_instance_profile_name
  root_volume_size = 20
  volume_type      = "gp2"
  ingress_ports    = [
    {
      from_port   = 6169
      to_port     = 6169
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      security_group_id = []
    },
    {
      from_port   = 6168
      to_port     = 6168
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      security_group_id = []
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = []
      security_group_id = [module.ansible.ansible_sg]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = []
      security_group_id = [module.openvpn.ssh_sg]
    }
  ]
  egress_ports     = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    }
  ]
}

module "skizzle_scheduler" {
  source           = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/skizzle?ref=TF_module"
  subnet           = module.network.private_subnet_ids[1]
  instance_ami     = var.tupacase_ami
  instance_name    = "Skizzle-Scheduler"
  instance_type    = "t3.medium"
  ssh_key_name     = aws_key_pair.ssh_key_pair.key_name
  vpc_cidr         = var.cidr
  #secure_ssh_sg    = module.openvpn.ssh_sg.id
  vpc_id           = module.network.vpc_id
  tags             = var.tags
  instance_profile = module.iam_ssm.ssm_instance_profile_name
  root_volume_size = 20
  volume_type      = "gp2"
  ingress_ports    = [
    {
      from_port   = 6169
      to_port     = 6169
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      security_group_id = []
    },
    {
      from_port   = 6168
      to_port     = 6168
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      security_group_id = []
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = []
      security_group_id = [module.ansible.ansible_sg]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = []
      security_group_id = [module.openvpn.ssh_sg]
    }
  ]
  egress_ports     = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    }
  ]
}

module "Glaretram_MQTT" {
  source           = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/glaretram_mtt?ref=TF_module"
  subnet           = module.network.private_subnet_ids[0]
  instance_ami     = var.glaretrammtt_ami
  instance_name    = var.glaretrammtt_name
  instance_type    = "t3.micro"
  ssh_key_name     = aws_key_pair.ssh_key_pair.key_name
  vpc_cidr         = var.cidr
  #secure_ssh_sg    = module.openvpn.ssh_sg.id
  vpc_id           = module.network.vpc_id
  tags             = var.tags
  instance_profile = module.iam_ssm.ssm_instance_profile_name
  root_volume_size = 20
  volume_type      = "gp2"
  # ebs_block_devices = [
  #   {
  #     # Data
  #     device_name           = "/dev/xvdba"
  #     volume_size           = 40
  #     volume_type           = "gp2"
  #   }
  # ]
  ingress_ports    = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_group_id = []
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_group_id = []
    },
    {
      from_port   = 43616
      to_port     = 43616
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_group_id = []
    },
    {
      from_port   = 43433
      to_port     = 43433
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_group_id = []
    },
    {
      from_port   = 2616
      to_port     = 2616
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_group_id = []
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = []
      security_group_id = [module.ansible.ansible_sg]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = []
      security_group_id = [module.openvpn.ssh_sg]
    }
  ]
  egress_ports     = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    }
  ]
}

module "Glaretram" {
  source           = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/glaretram?ref=TF_module"
  subnet           = module.network.private_subnet_ids[1]
  instance_ami     = var.glaretram_ami
  instance_name    = var.glaretram_name
  instance_type    = "t3.large"
  ssh_key_name     = aws_key_pair.ssh_key_pair.key_name
  vpc_cidr         = var.cidr
  #secure_ssh_sg    = module.openvpn.ssh_sg.id
  vpc_id           = module.network.vpc_id
  tags             = var.tags
  instance_profile = module.iam_ssm.ssm_instance_profile_name
  root_volume_size = 40
  volume_type      = "gp2"
  # ebs_block_devices = [
  #   {
  #     # Data
  #     device_name           = "/dev/xvdba"
  #     volume_size           = 40
  #     volume_type           = "gp2"
  #   }
  # ]
  ingress_ports    = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = []
      security_group_id = [module.ansible.ansible_sg]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = []
      security_group_id = [module.openvpn.ssh_sg]
    },    
    {
      from_port   = 21899
      to_port     = 21899
      protocol    = "tcp"
      cidr_blocks = ["163.35.0.0/16"]
      security_group_id = []
    }
  ]
  egress_ports     = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    }
  ]
}

  module "registration" {
    source           = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/registration?ref=TF_module"
    subnet           = module.network.private_subnet_ids[1]
    instance_ami     = var.registration_ami
    instance_name    = var.registration_name
    instance_type    = "t3.medium"
    ssh_key_name     = aws_key_pair.ssh_key_pair.key_name
    vpc_cidr         = var.cidr
    #secure_ssh_sg    = module.openvpn.ssh_sg.id
    vpc_id           = module.network.vpc_id
    tags             = var.tags
    instance_profile = module.iam_ssm.ssm_instance_profile_name
    root_volume_size = 20
    volume_type      = "gp2"
    # ebs_block_devices = [
    #   {
    #     # Data
    #     device_name           = "/dev/xvdba"
    #     volume_size           = 40
    #     volume_type           = "gp2"
    #   }
    # ]
    ingress_ports    = [
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = [var.cidr]
        security_group_id = []
      },
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = [var.cidr]
        security_group_id = []
      },
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = []
        security_group_id = [module.ansible.ansible_sg]
      },
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = []
        security_group_id = [module.openvpn.ssh_sg]
      }
    ]
    egress_ports     = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "tcp"
        cidr_blocks = [var.cidr]
      }
    ]
  }

module "my_asg" {
  source                     = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/Auto_scaling?ref=TF_module"
  create_alb_security_group  = true
  asg_name                   = "APIserver"
  min_size                   = 1
  max_size                   = 20
  desired_capacity           = 1
  vpc_id                     = module.network.vpc_id
  subnet_ids                 = module.network.private_subnet_ids
  launch_template_name       = "api-launch-template"
  launch_template_description= "Launch template for api ASG"
  image_id                   = var.tupacase_ami
  instance_type              = "t2.micro"
  iam_role_name              = "amazonssm-managedinstance-iam-role"
  iam_role_description       = "IAM role for AmazonSSMManagedInstanceCore ASG"
  security_group_id          = module.glaretram_alb_sg.security_group_id
  availability_zone          = "ca-central-1b"
  alb_subnets                = [module.network.private_subnet_ids[0] , module.network.private_subnet_ids[1]]
  alb_security_groups        = [module.my_asg.alb_security_group_id]
  ssl_certificate_arn        = "arn:aws:acm:ca-central-1:237781716992:certificate/0311f118-21c5-4edf-b375-2df2e3819e81"
}

module "iam_role_for_logs" {
  source = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/iam_role_for_logs?ref=TF_module"
  bucket_name = "stage-centralized-vpc-flow-logs-bucket"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for mobile_app identity for cloudfront to access s3 bucket"
}
module "cloudfront" {
  source                   = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/cloudfront?ref=TF_module"
  domain_name              = data.aws_s3_bucket.mobile_app_existing_bucket.bucket_domain_name
  origin_access_identity   = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
  price_class              = "PriceClass_200" # North America and Europe
  security_policy          = "TLSv1.2_2021"
  http_versions            = "http2"
  acm_certificate_arn      = "arn:aws:acm:us-east-1:237781716992:certificate/9a1d2c09-1d5b-4108-99f3-ee8bc4999370"
  ssl_support_method       = var.ssl_support_method
  minimum_protocol_version = "TLSv1.2_2021"
  aliases                  = ["appstage.aetonix.xyz"]
}
output "cloudfront_domain" {
  value = "module.my_cloudfront.cloudfront_domain"
}

# # # # reference to existing s3 bucket as cloudfront origin for mobile_app

data "aws_s3_bucket" "mobile_app_existing_bucket" {
  bucket = "aetonix-mockingbird-staging-env"
}
resource "aws_cloudfront_origin_access_identity" "dashboard_oai" {
  comment = "OAI for Dashboard cloudfront to access s3 bucket"
}
module "dashboard_cloudfront" {
  source                   = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/cloudfront?ref=TF_module"
  domain_name              = data.aws_s3_bucket.dashboard_existing_bucket.bucket_domain_name
  origin_access_identity   = aws_cloudfront_origin_access_identity.dashboard_oai.cloudfront_access_identity_path
  price_class              = "PriceClass_200" # North America and Europe
  security_policy          = "TLSv1.2_2021"
  http_versions            = "http2"
  acm_certificate_arn      = "arn:aws:acm:us-east-1:237781716992:certificate/9a1d2c09-1d5b-4108-99f3-ee8bc4999370"
  ssl_support_method       = var.ssl_support_method
  minimum_protocol_version = "TLSv1.2_2021"
  aliases                  = ["stagedashboard.aetonix.xyz"]
}
output "dashboard_cloudfront_domain" {
  value = "module.dashboard_cloudfront.cloudfront_domain"
}
data "aws_s3_bucket" "dashboard_existing_bucket" {
  bucket = "aetonix-dashboard-staging"  
}

module "opensearch" {
  source                = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/opensearch?ref=TF_module"
  domain_name           = "stagetest"
  elasticsearch_version = "OpenSearch_2.9"
  instance_type         = "r6g.large.elasticsearch"
  instance_count        = 2
  ebs_enabled           = true
  volume_size           = 20
  volume_type           = "gp2"
  subnet                = module.network.private_subnet_ids[0]
  vpc_id                = module.network.vpc_id

  ingress_ports    = [
    {
      description       = "HTTP"
      from_port         = 80
      to_port           = 80
      protocol          = "tcp"
      cidr_blocks       = ["0.0.0.0/0"]
      security_group_id = []
    },
    {
      description       = "HTTPS"
      from_port         = 443
      to_port           = 443
      protocol          = "tcp"
      cidr_blocks       = ["0.0.0.0/0"]
      security_group_id = []
    }
  ]
  egress_ports     = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    }
  ]
}


# # ########################################
# # # Create Application Load Balancer 
# # ########################################

module "Alb" {
  source                    = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/glaretram_alb?ref=TF_module"
  alb_name                  = "Stage-Alb"
  vpc_id                    = module.network.vpc_id
  subnets                   = [module.network.private_subnet_ids[0], module.network.private_subnet_ids[1]]
  glaretram_ec2_instance_id = module.Glaretram.instance_id
  alb_security_group        = module.glaretram_alb_sg.security_group_id
  acm_certificate_arn       = "arn:aws:acm:ca-central-1:237781716992:certificate/0311f118-21c5-4edf-b375-2df2e3819e81"
  alb_dns_name              = "api.aetonix.xyz"
}

# # ########################################
# # # Create Security Group for ALB
# # ########################################

module "glaretram_alb_sg" {
  source              = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/security_group?ref=TF_module"
  name                = "glaretram-alb-sg"
  description         = "Security group for Glaretram ALB"
  vpc_id              = module.network.vpc_id

  ingress_rules = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_group_id = []
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_group_id = []
    }
  ]
}

module "Alb_reg" {
  source                        = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/registration_alb?ref=TF_module"
  alb_name                      = "Registration-Alb"
  vpc_id                        = module.network.vpc_id
  subnets                       = [module.network.private_subnet_ids[0], module.network.private_subnet_ids[1]]
  registration_ec2_instance_id  = module.registration.instance_id
  alb_security_group            = module.registration_alb_sg.security_group_id
  acm_certificate_arn           = "arn:aws:acm:ca-central-1:237781716992:certificate/0311f118-21c5-4edf-b375-2df2e3819e81"
  alb_dns_name                  = "registration.aetonix.xyz"
}

# # ########################################
# # # Create Security Group for ALB
# # ########################################

module "registration_alb_sg" {
  source              = "git::git@github.com:Aetonix/dev-ops.git//Terraform/modules/security_group_new?ref=TF_module"
  name                = "registration-alb-sg"
  description         = "Security group for registration ALB"
  vpc_id              = module.network.vpc_id

  ingress_rules = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_group_id = []
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_group_id = []
    }
  ]
}
