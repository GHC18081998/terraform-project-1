# ==============================================================================
# Terraform & Provider Version Constraints for EKS Module
# ==============================================================================

terraform {
  # Variables are forbidden in this block by Terraform Core
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}
