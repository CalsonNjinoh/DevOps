output "vpc_id" {
  value = local.vpc_id
}

output "public_subnet_id" {
  value = aws_subnet.private[*].id
}

output "private_subnet_id" {
  value = aws_subnet.private[*].id
}

output "vpc_cidr_block" {
  value= var.vpc_cidr
}

output "ipv6_cidr_block" {
  value= aws_vpc.vpc[0].ipv6_cidr_block
}
