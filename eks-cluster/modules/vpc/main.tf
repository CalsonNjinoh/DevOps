locals {
  nat_name = "${terraform.workspace}-eks-vpc"
  private_subnets = matchkeys(var.subnet_list[*].cidr, var.subnet_list[*].type, ["private"])
  public_subnets = matchkeys(var.subnet_list[*].cidr, var.subnet_list[*].type, ["public"])
  private_tag_names = matchkeys(var.subnet_list[*].name, var.subnet_list[*].type, ["private"])
  public_tag_names = matchkeys(var.subnet_list[*].name, var.subnet_list[*].type, ["public"])
}

# Resource to create a new VPC
resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = true
  tags = merge({
    Name = var.name
  }, var.tags)
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge({
    Name = var.igw_name
  }, var.tags)
}

resource "aws_egress_only_internet_gateway" "ipv6_igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge({
    Name = "${var.igw_name}-ipv6"
  }, var.tags)
}

# Subnets
resource "aws_subnet" "private" {
  count                           = length(local.private_subnets)
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = local.private_subnets[count.index]
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, count.index + 2)
  assign_ipv6_address_on_creation = true

  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge({
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = ""
    Name                                = "${var.name}-${local.private_tag_names[count.index]}"
  }, var.tags)
  map_public_ip_on_launch = false
}

resource "aws_subnet" "public" {
  count                           = length(local.public_subnets)
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = local.public_subnets[count.index]
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, count.index)
  assign_ipv6_address_on_creation = true
  availability_zone               = data.aws_availability_zones.available.names[count.index]
  tags = merge({
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/elb"            = ""
    Name                                = "${var.name}-${local.public_tag_names[count.index]}"
  }, var.tags)
  map_public_ip_on_launch = true
}

# Public Route Table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge({
    Name = var.public_routetable_name
  }, var.tags)
}

resource "aws_route_table_association" "public" {
  count          = length(local.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}

# NAT Gateway
resource "aws_eip" "nat_ip" {
  domain = "vpc"
  tags = merge({
    Name = "${local.nat_name}-nat-ip"
  }, var.tags)
}

resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_route_table.public-route-table]
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.public[0].id
  tags = merge({
    Name = "${local.nat_name}-nat-gateway"
  }, var.tags)
}

# Private Route Table
resource "aws_route_table" "private-route-table" {
  depends_on = [
    aws_nat_gateway.nat_gateway,
    aws_egress_only_internet_gateway.ipv6_igw,
    aws_subnet.private
  ]
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = merge({
    Name = var.private_routetable_name
  }, var.tags)
}

resource "aws_route_table_association" "private" {
  count          = length(local.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private-route-table.id
}
