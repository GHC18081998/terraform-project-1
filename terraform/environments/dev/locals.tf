locals {
  common_tags = {
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
  }

  # Module paths
  modules_path = "../../modules/foundation"
}
