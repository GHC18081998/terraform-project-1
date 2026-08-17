# ==============================================================================
# KMS Key for RDS Encryption
# ==============================================================================

resource "aws_kms_key" "rds" {
  count = var.create_kms_key && var.storage_encrypted ? 1 : 0

  description             = "KMS key for RDS encryption - ${local.db_identifier}"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_key_rotation_enabled
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow RDS Service"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name    = local.kms_key_alias
    Purpose = "RDS Encryption"
  })
}

# ==============================================================================
# KMS Key Alias
# ==============================================================================

resource "aws_kms_alias" "rds" {
  count = var.create_kms_key && var.storage_encrypted ? 1 : 0

  name          = local.kms_key_alias
  target_key_id = aws_kms_key.rds[0].key_id
}

# ==============================================================================
# Data Sources
# ==============================================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ==============================================================================
# Locals for KMS Key Resolution
# ==============================================================================

locals {
  # Resolve which KMS key to use
  kms_key_id = var.storage_encrypted ? (
    var.create_kms_key ? (
      aws_kms_key.rds[0].arn
    ) : var.kms_key_id
  ) : null
}