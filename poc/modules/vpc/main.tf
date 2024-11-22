locals {
  public_subnet_name_prefix  = "Public Subnet"
  private_subnet_name_prefix = "Private Subnet"
  internet_gateway_suffix    = "Internet Gateway"
  nat_gateway_suffix         = "NAT Gateway"
  public_route_table_suffix  = "Public Routing"
  private_route_table_suffix = "Private Routing"
  #flow_logs_bucket_name      = "aetonix-dev-${lower(var.name)}-vpc-flow-logs"
  private_acl_name = "${var.name} Private ACL"
  public_acl_name  = "${var.name} Public ACL"

  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : 0
}


########################################
# VPC
########################################

resource "aws_vpc" "main" {
  cidr_block                       = var.cidr
  enable_dns_support               = var.enable_dns_hostnames
  enable_dns_hostnames             = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block = var.enable_public_ipv6

  tags = merge({
    Name = var.name
  }, var.tags)
}

########################################
# Subnets 
########################################

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  ipv6_cidr_block         = var.enable_public_ipv6 ? element(var.public_subnets_ipv6, count.index) : null
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge({
    Name = "${local.public_subnet_name_prefix} ${count.index + 1}"
  }, var.tags)
}


resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.azs, count.index)

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
  count = local.nat_gateway_count

  tags = merge({
    Name = "${var.name} ${local.nat_gateway_suffix}"
  }, var.tags)
}

resource "aws_nat_gateway" "nat" {
  count         = local.nat_gateway_count
  subnet_id     = element(aws_subnet.public_subnets[*].id, var.single_nat_gateway ? 0 : count.index)
  allocation_id = element(aws_eip.nat[*].id, var.single_nat_gateway ? 0 : count.index)

  tags = merge({
    Name = "${var.name} ${local.nat_gateway_suffix}"
  }, var.tags)
}

########################################
# Route Tables
########################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name = "${var.name} ${local.public_route_table_suffix}"
  }, var.tags)
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table" "private" {
  count  = local.nat_gateway_count
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name = "${var.name} ${local.private_route_table_suffix}"
  }, var.tags)
}

resource "aws_route" "private" {
  count                  = local.nat_gateway_count
  route_table_id         = element(aws_route_table.private[*].id, count.index)
  nat_gateway_id         = element(aws_nat_gateway.nat[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
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
  route_table_id = element(aws_route_table.private[*].id, var.single_nat_gateway ? 0 : count.index)
}

########################################
# VPC Flow Logs Log Destination S3
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



resource "aws_flow_log" "vpc_flow_logs" {
  count                = var.centralized_vpc_flow_logs_bucket_arn != "" ? 1 : 0
  log_destination      = var.centralized_vpc_flow_logs_bucket_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}

###################################################
# VPC Flow Logs Log Destination CloudWatch Log Group
###################################################

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = var.name
  retention_in_days = var.log_retention_days
}

resource "aws_flow_log" "vpc_flow_logs_cloudwatch" {
  count                    = var.cloudwatch_log_group_arn != "" ? 1 : 0
  log_destination          = var.cloudwatch_log_group_arn
  log_destination_type     = "cloud-watch-logs"
  traffic_type             = "ALL"
  max_aggregation_interval = var.max_aggregation_interval
  vpc_id                   = aws_vpc.main.id
}

########################################
# Network ACL
########################################

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name : local.private_acl_name
  }, var.tags)
}

resource "aws_network_acl_rule" "private_local" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  rule_action    = "allow"
  protocol       = -1
  egress         = false
  from_port      = 0
  to_port        = 0
  cidr_block     = var.cidr
}

resource "aws_network_acl_rule" "private_ephemeral" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 110
  rule_action    = "allow"
  protocol       = "tcp"
  egress         = false
  from_port      = 1024
  to_port        = 65535
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "private_http_out" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "tcp"
  egress         = true
  from_port      = 80
  to_port        = 80
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "private_https_out" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 110
  rule_action    = "allow"
  protocol       = "tcp"
  egress         = true
  from_port      = 443
  to_port        = 443
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "private_out_all" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 120
  rule_action    = "allow"
  protocol       = -1
  egress         = true
  from_port      = 0
  to_port        = 0
  cidr_block     = var.cidr
}

resource "aws_network_acl_rule" "private_out_ephemeral" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 130
  rule_action    = "allow"
  protocol       = "tcp"
  egress         = true
  from_port      = 1024
  to_port        = 65535
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name : local.public_acl_name
  }, var.tags)
}

resource "aws_network_acl_rule" "public_local" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "tcp"
  egress         = false
  from_port      = 22
  to_port        = 22
  cidr_block     = var.cidr
}

resource "aws_network_acl_rule" "public_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  rule_action    = "allow"
  protocol       = "tcp"
  egress         = false
  from_port      = 80
  to_port        = 80
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "public_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 120
  rule_action    = "allow"
  protocol       = "tcp"
  egress         = false
  from_port      = 443
  to_port        = 443
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "public_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 130
  rule_action    = "allow"
  protocol       = "tcp"
  egress         = false
  from_port      = 1024
  to_port        = 65535
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "public_out_all" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  rule_action    = "allow"
  protocol       = -1
  egress         = true
  from_port      = 0
  to_port        = 0
  cidr_block     = "0.0.0.0/0"
}


resource "aws_network_acl_association" "private" {
  count          = length(aws_subnet.private_subnets)
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

resource "aws_network_acl_association" "public" {
  count          = length(aws_subnet.public_subnets)
  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

########################################
# Default Security Group
########################################

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress = []
  egress  = []
}
