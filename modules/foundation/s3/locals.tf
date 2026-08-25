# ==============================================================
# Local Variables
# ==============================================================

locals {
  # Creates a consistent naming prefix (e.g., "webapp-prod")
  name_prefix = "${var.project_name}-${var.environment}"

  # Standardized tags applied to all buckets created by this module
  common_tags = {
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    Module      = "s3"
  }
}
