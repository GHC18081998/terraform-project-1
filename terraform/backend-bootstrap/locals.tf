# ==============================================================
# Data Sources
# ==============================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ==============================================================
# Local Variables
# ==============================================================

locals {
  # ------------------------------------------------------------
  # Account & Region
  # ------------------------------------------------------------
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # ------------------------------------------------------------
  # Common Tags
  # ------------------------------------------------------------
  common_tags = {
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    Component   = "State-Bootstrap" # Unified from S3/KMS/DynamoDB
  }

  # ------------------------------------------------------------
  # S3 Bucket Configuration
  # ------------------------------------------------------------
  bucket_name     = var.bucket_name
  log_bucket_name = var.log_bucket_name != "" ? var.log_bucket_name : "${var.bucket_name}-access-logs"

  # ------------------------------------------------------------
  # DynamoDB Configuration
  # ------------------------------------------------------------
  table_name          = var.table_name
  dynamodb_table_name = "${var.project_name}-terraform-lock"

  # ------------------------------------------------------------
  # KMS Configuration
  # ------------------------------------------------------------
  # Safely enforces the required 'alias/' prefix
  kms_alias = "alias/${var.kms_alias_name}"

  # Passed as a variable so Terraform waits for the key to be created
  kms_key_arn = var.kms_key_arn
}
