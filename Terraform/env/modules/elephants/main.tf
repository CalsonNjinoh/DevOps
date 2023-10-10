locals {
  instance_name      = "Elephant"
  vpn_sg_name        = "Elephants Access"
  vpn_sg_description = "Allow access to Redis"
}

########################################
# Arbiter NIC 
########################################

resource "aws_network_interface" "elephants" {
  count     = var.num_of_elephants
  subnet_id = element(var.subnets, count.index)

  tags = merge({
    Name = "${local.instance_name}"
  }, var.tags)
}


########################################
# Arbiter EC2 Instances
########################################

resource "aws_instance" "elephants" {
  count                = var.num_of_elephants
  ami                  = var.instance_ami
  instance_type        = var.instance_type
  key_name             = var.ssh_key_name
  iam_instance_profile = var.instance_profile

  root_block_device {
    volume_size           = var.root_volume_size
    #volume_type           = "gp2"
    volume_type           = var.volume_type
    encrypted             = true
    delete_on_termination = true
    tags = merge({
      Name : "${local.instance_name} Root"
    }, var.tags)
  }

  # Data
  ebs_block_device {
    #device_name           = "/dev/xvdba"
    device_name           = var.device_name
    volume_size           = var.block_volume_size
    #volume_type           = "gp2"
    volume_type           = var.volume_type
    encrypted             = true
    delete_on_termination = true
    tags = merge({
      Name : "${local.instance_name} Data"
    }, var.tags)
  }

  network_interface {
    network_interface_id = aws_network_interface.elephants[count.index].id
    device_index         = 0
  }

  tags = merge({
    Name : "${local.instance_name}"
  }, var.tags)
}


########################################
# Security Groups 
########################################

resource "aws_security_group" "elephants" {
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
  #   from_port   = 43616
  #   to_port     = 43616
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

resource "aws_network_interface_sg_attachment" "elephant_attachment" {
	count = var.num_of_elephants
  security_group_id    = aws_security_group.elephants.id
  network_interface_id = aws_network_interface.elephants[count.index].id
}

resource "aws_network_interface_sg_attachment" "ssh_attachment" {
	count = var.num_of_elephants
  security_group_id    = var.secure_ssh_sg
  network_interface_id = aws_network_interface.elephants[count.index].id
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
