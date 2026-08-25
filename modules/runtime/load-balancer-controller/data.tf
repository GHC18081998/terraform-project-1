# ==============================================================================
# Data Sources
# Location: modules/runtime/load-balancer-controller/data.tf
# ==============================================================================

#-------------------------------------------------------
# AWS Account & Region
#-------------------------------------------------------
data "aws_caller_identity" "current" {}

#-------------------------------------------------------
# IAM Policy Document - Trust Relationship (IRSA)
#-------------------------------------------------------
data "aws_iam_policy_document" "lb_controller_assume_role" {
  # Toggled by your environment variables
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_id}:aud"
      values   = [var.oidc_audience]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_id}:sub"
      values   = [local.service_account_full_name]
    }

    principals {
      identifiers = [local.oidc_provider_arn]
      type        = "Federated"
    }
  }
}
