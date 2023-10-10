locals {
  instance_name      = "OpenVPN"
  vpn_sg_name        = "OpenVPN"
  vpn_sg_description = "Allow access to OpenVPN"
  ssh_sg_name        = "SSH"
  ssh_sg_description = "Allow access to SSH on local network"
}

########################################
# VPN AMI
########################################

data "aws_ami" "openvpn" {
  most_recent = true

  filter {
    name   = "name"
    values = ["OpenVPN*"]
  }
}

########################################
# NIC 
########################################

resource "aws_network_interface" "openvpn" {
  subnet_id = var.subnet

  tags = merge({
    Name = local.instance_name
  }, var.tags)
}


########################################
# EC2 Instance 
########################################

resource "aws_instance" "openvpn" {
  ami                  = data.aws_ami.openvpn.id
  instance_type        = var.instance_type
  key_name             = var.ssh_key_name
  iam_instance_profile = var.instance_profile

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  network_interface {
    network_interface_id = aws_network_interface.openvpn.id
    device_index         = 0
  }

  tags = merge({
    Name : local.instance_name
  }, var.tags)
}


########################################
# Security Groups 
########################################

resource "aws_security_group" "openvpn" {
  name        = local.vpn_sg_name
  description = local.vpn_sg_description
  vpc_id      = var.vpc_id
  
  dynamic "ingress" {
    for_each      = var.openvpn_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }  
  }
  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = 1194
  #   to_port     = 1194
  #   protocol    = "udp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = 943
  #   to_port     = 943
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_security_group" "secure_ssh" {
  name        = local.ssh_sg_name
  description = local.ssh_sg_description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each      = var.ssh_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["${aws_instance.openvpn.private_ip}/32"]
    }  
  }
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["${aws_instance.openvpn.private_ip}/32"]
  # }

  tags = merge({
    Name = local.ssh_sg_name
  }, var.tags)
}

########################################
# Security Groups Attachment
########################################

resource "aws_network_interface_sg_attachment" "openvpn_attachment" {
  security_group_id    = aws_security_group.openvpn.id
  network_interface_id = aws_network_interface.openvpn.id
}

resource "aws_network_interface_sg_attachment" "ssh_attachment" {
  security_group_id    = aws_security_group.secure_ssh.id
  network_interface_id = aws_network_interface.openvpn.id
}


########################################
# Elastic IP
########################################

resource "aws_eip" "openvpn" {
  domain = "vpc"
}

resource "aws_eip_association" "openvpn" {
  instance_id   = aws_instance.openvpn.id
  allocation_id = aws_eip.openvpn.id
}

########################################
# Route 53
########################################

resource "aws_route53_record" "openvpn" {
  zone_id = var.route_53_zone_id
  name = var.domain_name
  type = "A"
  ttl = "300"
  records = [aws_eip.openvpn.public_ip]
}
