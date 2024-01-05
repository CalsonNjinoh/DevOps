locals {
  public_subnet_name_prefix  = "Public Subnet"
  private_subnet_name_prefix = "Private Subnet"
  internet_gateway_suffix    = "Internet Gateway"
  nat_gateway_suffix         = "NAT Gateway"
  public_route_table_suffix  = "Public Routing"
  private_route_table_suffix = "Private Routing"
  #flow_logs_bucket_name      = "aetonix-dev-${lower(var.name)}-vpc-flow-logs"
  private_acl_name = "${var.name} Private ACL"
  public_acl_name = "${var.name} Public ACL"
}


########################################
# VPC
########################################

resource "aws_vpc" "main" {
  cidr_block = var.cidr

  tags = merge({
    Name = var.name
  }, var.tags)
}

########################################
# Subnets 
########################################

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnets, count.index)
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge({
    Name = "${local.public_subnet_name_prefix} ${count.index + 1}"
  }, var.tags)
}


resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.private_subnets, count.index)
  availability_zone       = element(var.azs, count.index)

  tags = merge({
    Name = "${local.private_subnet_name_prefix} ${count.index + 1}"
  }, var.tags)
}

########################################
# Internet Gateway
########################################

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name = "${var.name} ${local.internet_gateway_suffix}"
  }, var.tags)
}

########################################
# NAT Gateway
########################################

resource "aws_eip" "nat" {
  //domain = "vpc"

  tags = merge({
    Name = "${var.name} ${local.nat_gateway_suffix}"
  }, var.tags)
}

resource "aws_nat_gateway" "nat" {
  subnet_id     = element(aws_subnet.public_subnets[*].id, 0)
  allocation_id = aws_eip.nat.id

  tags = merge({
    Name = "${var.name} ${local.nat_gateway_suffix}"
 }, var.tags)
}

########################################
# Route Tables
########################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge({
    Name = "${var.name} ${local.public_route_table_suffix}"
  }, var.tags)
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge({
    Name = "${var.name} ${local.private_route_table_suffix}"
  }, var.tags)
}

########################################
# Route Table Associations
########################################

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private.id
}

########################################
# Flow logs
########################################

#resource "aws_s3_bucket" "vpc_flow_logs" {
  #bucket = local.flow_logs_bucket_name
  #force_destroy = true
#}

#resource "aws_s3_bucket_ownership_controls" "vpc_flow_logs" {
  #bucket = aws_s3_bucket.vpc_flow_logs.id
  #rule {
    #object_ownership = "BucketOwnerPreferred"
  #}
#}

#resource "aws_s3_bucket_acl" "vpc_flow_logs" {
  #depends_on = [aws_s3_bucket_ownership_controls.vpc_flow_logs]

  #bucket = aws_s3_bucket.vpc_flow_logs.id
  #acl    = "private"
#}

//resource "aws_flow_log" "vpc_flow_logs" {
  //log_destination      = var.centralized_vpc_flow_logs_bucket_arn
  //log_destination_type = "s3"
  //traffic_type         = "ALL"
  //vpc_id               = aws_vpc.main.id
//}

########################################
# Network ACL
########################################

resource "aws_network_acl" "private" {
	vpc_id = aws_vpc.main.id

	ingress {
		protocol = -1
		rule_no = 100
		action = "allow"
		cidr_block = var.cidr
		from_port = 0
		to_port = 0
	}

	ingress {
		protocol = "tcp"
		rule_no = 110
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 1024
		to_port = 65535
	}

	egress {
		protocol = "tcp"
		rule_no = 100
		cidr_block = "0.0.0.0/0"
		action = "allow"
		to_port = 80
		from_port = 80
	}

	egress {
		protocol = "tcp"
		rule_no = 110
		cidr_block = "0.0.0.0/0"
		action = "allow"
		to_port = 443
		from_port = 443
	}

	egress {
		protocol = -1
		rule_no = 120
		action = "allow"
		cidr_block = var.cidr
		from_port = 0
		to_port = 0
	}

	egress {
		protocol = "tcp"
		rule_no = 130
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 1024
		to_port = 65535
	}

	tags = merge({
		Name: local.private_acl_name
	}, var.tags)
}

resource "aws_network_acl" "public" {
	vpc_id = aws_vpc.main.id

	ingress {
		protocol = "tcp"
		rule_no = 100
		action = "allow"
		cidr_block = var.cidr
		from_port = 22
		to_port = 22
	}

	ingress {
		protocol = "tcp"
		rule_no = 110
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 80
		to_port = 80
	}

	ingress {
		protocol = "tcp"
		rule_no = 120
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 443
		to_port = 443
	}

	ingress {
		protocol = "udp"
		rule_no = 130
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 1194
		to_port = 1194
	}

	ingress {
		protocol = "tcp"
		rule_no = 140
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 943
		to_port = 943
	}

	ingress {
		protocol = "tcp"
		rule_no = 150
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 1024
		to_port = 65535
	}

	egress {
		protocol = -1
		rule_no = 100
		cidr_block = "0.0.0.0/0"
		action = "allow"
		to_port = 0
		from_port = 0
	}

	tags = merge({
		Name: local.public_acl_name
	}, var.tags)
}

resource "aws_network_acl_association" "private" {
	count = length(aws_subnet.private_subnets)
	network_acl_id = aws_network_acl.private.id
	subnet_id = aws_subnet.private_subnets[count.index].id
}

resource "aws_network_acl_association" "public" {
	count = length(aws_subnet.public_subnets)
	network_acl_id = aws_network_acl.public.id
	subnet_id = aws_subnet.public_subnets[count.index].id
} 

########################################
# Default Security Group
########################################

resource "aws_default_security_group" "default" {
	vpc_id = aws_vpc.main.id

	ingress = []
	egress = []
}
