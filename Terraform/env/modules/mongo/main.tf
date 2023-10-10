locals {
  instance_name      = "MongoDB"
  vpn_sg_name        = "MongoDB Access"
  vpn_sg_description = "Allow access to MongoDB"
}

########################################
# Replica NIC 
########################################

resource "aws_network_interface" "mongo" {
  count     = var.num_of_replicas
  subnet_id = element(var.subnets, count.index)

  tags = merge({
    Name = "${local.instance_name} ${count.index}"
  }, var.tags)
}


########################################
# Replica EC2 Instances
########################################

resource "aws_instance" "mongo" {
  count                = var.num_of_replicas
  ami                  = var.instance_ami
  instance_type        = var.replica_instance_type
  key_name             = var.ssh_key_name
  iam_instance_profile = var.instance_profile

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
    tags = merge({
      Name : "${local.instance_name} Replica ${count.index} Root"
    }, var.tags)
  }

  dynamic "ebs_block_device" {
    for_each = var.mongo_ebs_block_device
    content {
      device_name           = block_device.value["device_name"]
      volume_size           = block_device.value["volume_size"]
      volume_type           = block_device.value["volume_type"]
      iops                  = block_device.value["iops"]
      encrypted             = true
      delete_on_termination = block_device.value["delete_on_termination"]
      tags                  = merge({ Name : "${local.instance_name} Replica ${count.index} Data" }, var.tags)
    }
  }
  # # Data
  # ebs_block_device {
  #   device_name           = "/dev/xvdba"
  #   volume_size           = 50
  #   volume_type           = "io1"
  #   iops                  = "1000"
  #   encrypted             = true
  #   delete_on_termination = true
  #   tags = merge({
  #     Name : "${local.instance_name} Replica ${count.index} Data"
  #   }, var.tags)
  # }

  # # Journal
  # ebs_block_device {
  #   device_name           = "/dev/xvdbb"
  #   volume_size           = 30
  #   volume_type           = "io1"
  #   iops                  = "250"
  #   encrypted             = true
  #   delete_on_termination = true
  #   tags = merge({
  #     Name : "${local.instance_name} Replica ${count.index} Journal"
  #   }, var.tags)
  # }

  # # Log
  # ebs_block_device {
  #   device_name           = "/dev/xvdbc"
  #   volume_size           = 31
  #   volume_type           = "io1"
  #   iops                  = "100"
  #   encrypted             = true
  #   delete_on_termination = true
  #   tags = merge({
  #     Name : "${local.instance_name} Replica ${count.index} Log"
  #   }, var.tags)
  # }

  network_interface {
    network_interface_id = aws_network_interface.mongo[count.index].id
    device_index         = 0
  }

  tags = merge({
    Name : "${local.instance_name} Replica ${count.index}"
  }, var.tags)
}


########################################
# Arbiter NIC 
########################################

resource "aws_network_interface" "arbiter" {
  subnet_id = var.subnets[0]

  tags = merge({
    Name = "${local.instance_name} Arbiter"
  }, var.tags)
}


########################################
# Arbiter EC2 Instances
########################################

resource "aws_instance" "arbiter" {
  ami                  = var.instance_ami
  instance_type        = var.arbiter_instance_type
  key_name             = var.ssh_key_name
  iam_instance_profile = var.instance_profile

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
    tags = merge({
      Name : "${local.instance_name} Arbiter Root"
    }, var.tags)
  }
  dynamic "ebs_block_device" {
    for_each = var.arbiter_ebs_block_device
    content {
      device_name           = block_device.value["device_name"]
      volume_size           = block_device.value["volume_size"]
      volume_type           = block_device.value["volume_type"]
      encrypted             = true
      delete_on_termination = block_device.value["delete_on_termination"]
      tags                  = merge({ Name : "${local.instance_name} Replica ${count.index} Data" }, var.tags)
    }
  }
  # # Data
  # ebs_block_device {
  #   device_name           = "/dev/xvdba"
  #   volume_size           = 20
  #   volume_type           = "gp2"
  #   encrypted             = true
  #   delete_on_termination = true
  #   tags = merge({
  #     Name : "${local.instance_name} Arbiter Data"
  #   }, var.tags)
  # }

  network_interface {
    network_interface_id = aws_network_interface.arbiter.id
    device_index         = 0
  }

  tags = merge({
    Name : "${local.instance_name} Arbiter"
  }, var.tags)
}


########################################
# Security Groups 
########################################

resource "aws_security_group" "mongo" {
  name        = local.vpn_sg_name
  description = local.vpn_sg_description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each      = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }  
  }
  # ingress {
  #   from_port   = 7616
  #   to_port     = 7616
  #   protocol    = "tcp"
  #   cidr_blocks = [var.vpc_cidr]
  # }

  dynamic "egress" {
    for_each      = var.egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }  
  }

  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = merge({
    Name = local.vpn_sg_name
  }, var.tags)
}

########################################
# Security Groups Attachment
########################################

resource "aws_network_interface_sg_attachment" "replica_mongo_attachment" {
  count                = var.num_of_replicas
  security_group_id    = aws_security_group.mongo.id
  network_interface_id = aws_network_interface.mongo[count.index].id
}

resource "aws_network_interface_sg_attachment" "arbiter_mongo_attachment" {
  security_group_id    = aws_security_group.mongo.id
  network_interface_id = aws_network_interface.arbiter.id
}

resource "aws_network_interface_sg_attachment" "ssh_attachment_replica" {
  count                = var.num_of_replicas
  security_group_id    = var.secure_ssh_sg
  network_interface_id = aws_network_interface.mongo[count.index].id
}

resource "aws_network_interface_sg_attachment" "ssh_attachment_arbiter" {
  security_group_id    = var.secure_ssh_sg
  network_interface_id = aws_network_interface.arbiter.id
}

########################################
# Route 53
########################################

# resource "aws_route53_record" "openvpn" {
#   zone_id = var.route_53_zone_id
#   name    = var.domain_name
#   type    = "A"
#   ttl     = "300"
#   records = [aws_eip.openvpn.public_ip]
# }
