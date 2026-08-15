# ==============================================================
# TEST Environment Outputs
# ==============================================================

output "environment" {
  description = "Current environment name"
  value       = local.environment
}

# ---- VPC Outputs ----
output "vpc_ids" {
  description = "All VPC IDs in TEST environment"
  value       = module.vpc.vpc_ids
}

output "vpc_cidr_blocks" {
  description = "All VPC CIDR blocks in TEST environment"
  value       = module.vpc.vpc_cidr_blocks
}

# ---- IGW Outputs ----
output "igw_ids" {
  description = "All Internet Gateway IDs"
  value       = module.vpc.igw_ids
}

# ---- Public Subnet Outputs ----
output "public_subnet_ids" {
  description = "All public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "public_subnet_cidr_blocks" {
  description = "All public subnet CIDR blocks"
  value       = module.vpc.public_subnet_cidr_blocks
}

# ---- Private Subnet Outputs ----
output "private_subnet_ids" {
  description = "All private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "private_subnet_cidr_blocks" {
  description = "All private subnet CIDR blocks"
  value       = module.vpc.private_subnet_cidr_blocks
}

# ---- NAT Gateway Outputs ----
output "nat_gateway_ids" {
  description = "All NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "NAT Gateway public IPs"
  value       = module.vpc.nat_gateway_public_ips
}

# ---- Route Table Outputs ----
output "public_route_table_ids" {
  description = "Public route table IDs"
  value       = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "Private route table IDs"
  value       = module.vpc.private_route_table_ids
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

# ---- ECR Outputs ----
output "test_repository_urls" {
  description = "The ECR URLs for the test repositories"
  value       = module.ecr_registry.repository_urls
}

output "test_repository_arns" {
  description = "The IAM ARNs for the test repositories"
  value       = module.ecr_registry.repository_arns
}

output "test_repository_names" {
  description = "The actual deployed names of the test repositories"
  value       = module.ecr_registry.repository_names
}

# ==============================================================================
# RDS Instance Outputs
# ==============================================================================

output "db_instance_id" {
  description = "RDS instance identifier"
  value       = module.rds.db_instance_id
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = module.rds.db_instance_port
}

output "db_instance_name" {
  description = "Database name"
  value       = module.rds.db_instance_name
}

output "db_instance_engine_version" {
  description = "Database engine version"
  value       = module.rds.db_instance_engine_version
}

output "db_secret_arn" {
  description = "Secrets Manager ARN for DB credentials"
  value       = module.rds.db_secret_arn
}

output "security_group_id" {
  description = "Security group ID for RDS"
  value       = module.rds.security_group_id
}

output "db_subnet_group_id" {
  description = "DB subnet group ID"
  value       = module.rds.db_subnet_group_id
}

# ---- Summary ----
output "infrastructure_summary" {
  description = "Complete infrastructure summary for TEST environment"
  value = {
    environment     = var.environment
    region          = var.aws_region
    vpc_count       = length(module.vpc.vpc_ids)
    public_subnets  = length(module.vpc.public_subnet_ids)
    private_subnets = length(module.vpc.private_subnet_ids)
    nat_gateways    = length(module.vpc.nat_gateway_ids)
    s3_bucket_count = length(module.s3.bucket_ids)
    ecr_repo_count  = length(module.ecr_registry.repository_names)
    database_ready  = true
  }
}