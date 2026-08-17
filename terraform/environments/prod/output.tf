# ==============================================================
# PROD Environment - Outputs
# ==============================================================
# Location: environments/prod/output.tf

output "environment" {
  description = "Current environment name"
  value       = var.environment
}

# --------------------------------------------------------------
# VPC Outputs (Multi-VPC Map Support)
# --------------------------------------------------------------
output "vpc_ids" {
  description = "Map of production VPC IDs"
  value       = module.vpc.vpc_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs across VPCs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs across VPCs"
  value       = module.vpc.public_subnet_ids
}

# --------------------------------------------------------------
# ECR Outputs (Corrected to match module "ecr_registry")
# --------------------------------------------------------------
output "prod_repository_urls" {
  description = "The ECR repository URLs"
  value       = module.ecr_registry.repository_urls
}

output "prod_repository_names" {
  description = "The deployed names of the ECR repositories"
  value       = module.ecr_registry.repository_names
}

# --------------------------------------------------------------
# EKS & Karpenter Outputs
# --------------------------------------------------------------
output "eks_cluster_name" {
  description = "Name of the production EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS Kubernetes API"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

# --------------------------------------------------------------
# RDS Instance Outputs
# --------------------------------------------------------------
output "db_instance_id" {
  description = "RDS instance identifier"
  value       = module.rds.db_instance_id
}

output "db_instance_endpoint" {
  description = "RDS instance connection endpoint"
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

output "db_secret_arn" {
  description = "Secrets Manager ARN for database credentials"
  value       = module.rds.db_secret_arn
}

output "db_security_group_id" {
  description = "Security group ID for RDS"
  value       = module.rds.security_group_id
}

# --------------------------------------------------------------
# Infrastructure Summary
# --------------------------------------------------------------
output "infrastructure_summary" {
  description = "Complete infrastructure summary for production"
  value = {
    environment    = var.environment
    region         = var.aws_region
    public_subnets = length(module.vpc.public_subnet_ids)
    private_subnets = length(module.vpc.private_subnet_ids)
    ecr_repos      = length(module.ecr_registry.repository_names)
    eks_cluster    = module.eks.cluster_name
    database_ready = true
  }
}