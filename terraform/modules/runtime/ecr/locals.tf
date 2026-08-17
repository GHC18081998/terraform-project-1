locals {
  use_kms = var.create_kms_key || var.kms_key_arn != null

  kms_key_name_tag = "${var.environment}-ecr-kms-key"

  kms_alias_name   = "alias/${var.environment}-ecr-kms-key"

  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "ECR"
    },
    var.extra_tags
  )
}
