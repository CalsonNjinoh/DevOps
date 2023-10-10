locals {
  instance_name      = "Redis"
  vpn_sg_name        = "Redis Access"
  vpn_sg_description = "Allow access to Redis"
}

########################################
# Arbiter NIC 
########################################

resource "aws_network_interface" "redis" {
  subnet_id = var.subnet

  tags = merge({
    Name = "${local.instance_name}"
  }, var.tags)
}


########################################
# Arbiter EC2 Instances
########################################

resource "aws_instance" "redis" {
  ami                  = var.instance_ami
  instance_type        = var.instance_type
  key_name             = var.ssh_key_name
  iam_instance_profile = var.instance_profile

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.volume_type
    encrypted             = true
    delete_on_termination = true
    tags = merge({
      Name : "${local.instance_name} Root"
    }, var.tags)
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
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
  #   volume_size           = 40
  #   volume_type           = "gp2"
  #   encrypted             = true
  #   delete_on_termination = true
  #   tags = merge({
  #     Name : "${local.instance_name} Data"
  #   }, var.tags)
  # }

  network_interface {
    network_interface_id = aws_network_interface.redis.id
    device_index         = 0
  }

  tags = merge({
    Name : "${local.instance_name}"
  }, var.tags)
}


########################################
# Security Groups 
########################################

resource "aws_security_group" "redis" {
  name        = local.vpn_sg_name
  description = local.vpn_sg_description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each      = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    }  
  }
  # ingress {
  #   from_port   = 6169
  #   to_port     = 6169
  #   protocol    = "tcp"
  #   cidr_blocks = [var.vpc_cidr]
  # }

  # ingress {
  #   from_port   = 6168
  #   to_port     = 6168
  #   protocol    = "tcp"
  #   cidr_blocks = [var.vpc_cidr]
  # }

  dynamic "egress" {
    for_each      = var.egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
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

resource "aws_network_interface_sg_attachment" "redis_attachment" {
  security_group_id    = aws_security_group.redis.id
  network_interface_id = aws_network_interface.redis.id
}

resource "aws_network_interface_sg_attachment" "ssh_attachment" {
  security_group_id    = var.secure_ssh_sg
  network_interface_id = aws_network_interface.redis.id
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
