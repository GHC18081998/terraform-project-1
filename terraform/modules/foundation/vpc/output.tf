# ==============================================================
# VPC Outputs
# ==============================================================

output "vpc_ids" {
  description = "Map of VPC name to VPC ID"
  value       = { for k, v in aws_vpc.this : k => v.id }
}

output "vpc_arns" {
  description = "Map of VPC name to VPC ARN"
  value       = { for k, v in aws_vpc.this : k => v.arn }
}

output "vpc_cidr_blocks" {
  description = "Map of VPC name to CIDR block"
  value       = { for k, v in aws_vpc.this : k => v.cidr_block }
}

output "igw_ids" {
  description = "Map of VPC name to Internet Gateway ID"
  value       = { for k, v in aws_internet_gateway.this : k => v.id }
}

output "public_subnet_ids" {
  description = "Map of subnet name to subnet ID"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "public_subnet_cidr_blocks" {
  description = "Map of subnet name to CIDR block"
  value       = { for k, v in aws_subnet.public : k => v.cidr_block }
}

output "private_subnet_ids" {
  description = "Map of subnet name to subnet ID"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "private_subnet_cidr_blocks" {
  description = "Map of subnet name to CIDR block"
  value       = { for k, v in aws_subnet.private : k => v.cidr_block }
}

output "nat_gateway_ids" {
  description = "Map of NAT Gateway name to ID"
  value       = { for k, v in aws_nat_gateway.this : k => v.id }
}

output "nat_gateway_public_ips" {
  description = "Map of NAT Gateway name to public IP"
  value       = { for k, v in aws_eip.nat : k => v.public_ip }
}

output "public_route_table_ids" {
  description = "Map of route table name to ID"
  value       = { for k, v in aws_route_table.public : k => v.id }
}

output "private_route_table_ids" {
  description = "Map of route table name to ID"
  value       = { for k, v in aws_route_table.private : k => v.id }
}