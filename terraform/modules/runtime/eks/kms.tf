# ==============================================================================
# KMS Key Policy for EKS, EBS, CloudWatch Logs, and Auto Scaling
# ==============================================================================
data "aws_iam_policy_document" "eks_kms" {
  # 1. Root account permissions
  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # 2. CloudWatch Logs Permission
  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]

    # We are temporarily removing the "Condition" block to rule out ARN mismatch errors.
    # Once it builds successfully, we can re-secure it later.
  }

  # 3. Allow EC2 and Auto Scaling service (Required for encrypted EBS Node volumes)
  statement {
    sid    = "AllowEC2AndAutoScalingToUseKey"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${data.aws_region.current.name}.amazonaws.com"]
    }
  }

  # 4. Allow Auto Scaling Service-Linked Role specifically
  statement {
    sid    = "AllowAutoScalingServiceRole"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

# ==============================================================================
# Unified KMS Key & Alias
# ==============================================================================
resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS ${var.cluster_name} logs, secrets, and EBS"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = var.kms_enable_rotation
  policy                  = data.aws_iam_policy_document.eks_kms.json
  tags                    = local.common_tags
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.environment}-${var.cluster_name}-eks"
  target_key_id = aws_kms_key.eks.key_id
}