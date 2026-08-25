# ============================================================
# Core AWS Identity & Context
# ============================================================
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

# ============================================================
# KMS — Existing Key Validation
# Used when create_kms_key = false and an ARN is supplied
# ============================================================
data "aws_kms_key" "existing_ecr_key" {
  count  = local.use_kms && !var.create_kms_key && var.kms_key_arn != null ? 1 : 0
  key_id = var.kms_key_arn
}

# ============================================================
# KMS — New Key Policy (ADD THIS)
# Required when create_kms_key = true to grant access to the key
# ============================================================
data "aws_iam_policy_document" "ecr_kms_key_policy" {
  count = var.create_kms_key && local.use_kms ? 1 : 0

  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}
