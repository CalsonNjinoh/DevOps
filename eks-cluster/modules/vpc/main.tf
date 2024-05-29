locals {
  nat_name = "${terraform.workspace}-eks-vpc"
  vpc_id   = element(coalescelist(data.aws_vpc.vpc.*.id, aws_vpc.vpc.*.id, [""]), 0)

  private          = matchkeys(var.subnet_list[*].cidr, var.subnet_list[*].type, ["private"])
  public           = matchkeys(var.subnet_list[*].cidr, var.subnet_list[*].type, ["public"])
  private_tag_name = matchkeys(var.subnet_list[*].name, var.subnet_list[*].type, ["private"])
  public_tag_name  = matchkeys(var.subnet_list[*].name, var.subnet_list[*].type, ["public"])
}

################################################################################
# VPC
################################################################################
data "aws_vpc" "vpc" {
  count = var.vpc_id != "" ? 1 : 0
  id    = var.vpc_id
}

resource "aws_vpc" "vpc" {
  count                            = var.vpc_id == "" ? 1 : 0
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

#####
# IGW
#####

resource "aws_internet_gateway" "igw" {
  depends_on = [
    aws_vpc.vpc
  ]
  vpc_id = local.vpc_id
  tags = merge({
    Name = var.igw_name
  }, var.tags)
}

resource "aws_egress_only_internet_gateway" "ipv6_igw" {
  vpc_id = local.vpc_id

  depends_on = [
    aws_vpc.vpc
  ]
  tags = merge({
    Name = "${var.igw_name}-ipv6"
  }, var.tags)

}

################################################################################
# Subnets
################################################################################
resource "aws_subnet" "private" {
  depends_on = [
    aws_vpc.vpc
  ]
  count                           = length(local.private)
  vpc_id                          = local.vpc_id
  cidr_block                      = local.private[count.index]
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc[0].ipv6_cidr_block, 8, count.index + 2)
  assign_ipv6_address_on_creation = true

  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge({
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = ""
    Name                                = "${var.name}-${local.private_tag_name[count.index]}"
  }, var.tags)
  map_public_ip_on_launch = false
}
resource "aws_subnet" "public" {
  depends_on = [
    aws_vpc.vpc
  ]
  count                           = length(local.public)
  vpc_id                          = local.vpc_id
  cidr_block                      = local.public[count.index]
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc[0].ipv6_cidr_block, 8, count.index)
  assign_ipv6_address_on_creation = true
  availability_zone               = data.aws_availability_zones.available.names[count.index]
  tags = merge({
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/elb"            = ""
    Name                                = "${var.name}-${local.public_tag_name[count.index]}"
  }, var.tags)
  map_public_ip_on_launch = false
}


################################################################################
# Route tables
################################################################################

resource "aws_route_table" "public-route-table" {
  depends_on = [
    aws_internet_gateway.igw,
    aws_subnet.public
  ]
  vpc_id = local.vpc_id

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
  depends_on = [
    aws_route_table.public-route-table
  ]
  count          = length(local.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}

#####
# NG
#####
resource "aws_eip" "nat_ip" {
  domain      = "vpc" # New attribute to specify the EIP domain as "vpc"
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

####
# Private
#####




resource "aws_route_table" "private-route-table" {
  depends_on = [
    aws_nat_gateway.nat_gateway,
    aws_egress_only_internet_gateway.ipv6_igw,
    aws_subnet.private
  ]
  vpc_id = local.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  

  tags = merge({
    Name = var.private_routetable_name
  }, var.tags)
}
resource "aws_route_table_association" "private" {
  depends_on = [
    aws_route_table.private-route-table
  ]
  count          = length(local.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private-route-table.id
}

###############



