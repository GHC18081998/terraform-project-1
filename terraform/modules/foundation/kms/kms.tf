# ==============================================================
# KMS Key
# ==============================================================

resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  # References the generated JSON from data.tf
  policy = data.aws_iam_policy_document.kms_key_policy.json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${var.key_purpose}-kms"
  })
}