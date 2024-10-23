output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "public_route_table" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = [for rt in aws_route_table.private : rt.id]
}

output "public_network_acl" {
  value = aws_network_acl.public.id
}

output "private_network_acl" {
  value = aws_network_acl.private.id
}

output "private_route_table" {
  value = [for rt in aws_route_table.private : rt.id]
}
