# ==============================================================
# Global Data Sources
# ==============================================================

data "aws_caller_identity" "current" {}

# ==============================================================
# Standard roles (assumed by AWS services or other AWS accounts)
# ==============================================================

data "aws_iam_policy_document" "assume_role" {
  for_each = var.roles

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = each.value.principal_type
      identifiers = each.value.principal_identifiers
    }

    dynamic "condition" {
      for_each = each.value.external_id == null ? [] : [each.value.external_id]
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [condition.value]
      }
    }
  }
}

# ==============================================================
# OIDC-federated roles (assumed by CI/CD via sts:AssumeRoleWithWebIdentity)
# ==============================================================

data "aws_iam_policy_document" "oidc_assume_role" {
  for_each = var.oidc_roles

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      # Updated from .this to .providers
      identifiers = [aws_iam_openid_connect_provider.providers[each.value.provider_key].arn]
    }

    condition {
      test     = "StringEquals"
      # Updated from .this to .providers
      variable = "${replace(aws_iam_openid_connect_provider.providers[each.value.provider_key].url, "https://", "")}:aud"
      values   = [each.value.audience]
    }

    condition {
      test     = "StringLike"
      # Updated from .this to .providers
      variable = "${replace(aws_iam_openid_connect_provider.providers[each.value.provider_key].url, "https://", "")}:sub"
      values   = each.value.subject_claims
    }
  }
}