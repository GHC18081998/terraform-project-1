# ============================================================
# KMS Key — ECR Image Encryption
# All values sourced from variables and locals
# ============================================================
resource "aws_kms_key" "ecr" {
  count = var.create_kms_key && local.use_kms ? 1 : 0

  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = var.kms_key_enable_rotation
  multi_region            = var.kms_key_multi_region
  policy                  = data.aws_iam_policy_document.ecr_kms_key_policy[0].json

  tags = merge(local.common_tags, {
    Name      = local.kms_key_name_tag
    Purpose   = "ecr-encryption"
    Component = "kms"
  })
}

# ============================================================
# KMS Alias
# Name derived from locals (project + environment)
# ============================================================
resource "aws_kms_alias" "ecr" {
  count = var.create_kms_key && local.use_kms ? 1 : 0

  name          = local.kms_alias_name
  target_key_id = aws_kms_key.ecr[0].key_id
}