# ---- VPC Outputs ----
output "vpc_ids" {
  description = "All VPC IDs in DEV environment"
  value       = module.networking.vpc_ids
}

output "vpc_cidr_blocks" {
  description = "All VPC CIDR blocks in DEV environment"
  value       = module.networking.vpc_cidr_blocks
}

# ---- IGW Outputs ----
output "igw_ids" {
  description = "All Internet Gateway IDs"
  value       = module.networking.igw_ids
}

# ---- Public Subnet Outputs ----
output "public_subnet_ids" {
  description = "All public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "public_subnet_cidr_blocks" {
  description = "All public subnet CIDR blocks"
  value       = module.networking.public_subnet_cidr_blocks
}

# ---- Private Subnet Outputs ----
output "private_subnet_ids" {
  description = "All private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "private_subnet_cidr_blocks" {
  description = "All private subnet CIDR blocks"
  value       = module.networking.private_subnet_cidr_blocks
}

# ---- NAT Gateway Outputs ----
output "nat_gateway_ids" {
  description = "All NAT Gateway IDs"
  value       = module.networking.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "NAT Gateway public IPs"
  value       = module.networking.nat_gateway_public_ips
}

# ---- Route Table Outputs ----
output "public_route_table_ids" {
  description = "Public route table IDs"
  value       = module.networking.public_route_table_ids
}

output "private_route_table_ids" {
  description = "Private route table IDs"
  value       = module.networking.private_route_table_ids
}

# ---- S3 Outputs ----
output "s3_bucket_ids" {
  description = "Map of bucket keys to their generated S3 bucket IDs (names)"
  value       = module.s3.bucket_ids
}

output "s3_bucket_arns" {
  description = "Map of bucket keys to their corresponding S3 bucket ARNs"
  value       = module.s3.bucket_arns
}

# ---- Summary ----
output "networking_summary" {
  description = "Complete networking summary for DEV environment"
  value = {
    environment     = var.environment
    region          = var.aws_region
    vpc_count       = length(module.networking.vpc_ids)
    public_subnets  = length(module.networking.public_subnet_ids)
    private_subnets = length(module.networking.private_subnet_ids)
    nat_gateways    = length(module.networking.nat_gateway_ids)
    s3_bucket_count = length(module.s3.bucket_ids)
  }
}