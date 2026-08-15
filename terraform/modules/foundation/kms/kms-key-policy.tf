# ==============================================================
# KMS Key Policy Configuration
# ==============================================================

# Fetches the AWS Account ID of the user/role running Terraform
data "aws_caller_identity" "current" {}

# Builds the JSON policy for the KMS Key
data "aws_iam_policy_document" "kms_key_policy" {

  # 1. Mandatory Root Access (Prevents locking yourself out of the key)
  statement {
    sid       = "EnableRootAccountAccess"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # 2. Service Access (Only added if allowed_service_principals is provided in variables)
  dynamic "statement" {
    for_each = length(var.allowed_service_principals) > 0 ? [1] : []
    content {
      sid    = "AllowServiceUsage"
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals {
        type        = "Service"
        identifiers = var.allowed_service_principals
      }
    }
  }
}