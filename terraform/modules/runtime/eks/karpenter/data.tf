# ==============================================================================
# AWS Account & Region Context Data Sources
# ==============================================================================
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

# ==============================================================================
# VPC & Subnet Data Sources
# ==============================================================================
data "aws_subnets" "karpenter" {
  filter {
    name   = "subnet-id"
    values = var.private_subnet_ids
  }
}

# ==============================================================================
# EKS Optimized AMI Lookup (SSM Parameter Store)
# ==============================================================================
data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${var.cluster_version}/amazon-linux-2/recommended/image_id"
}