# ==============================================================
# Local Variables
# ==============================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    Module      = "kms"
  }
}