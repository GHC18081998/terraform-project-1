# ==============================================================================
# IRSA - AWS Load Balancer Controller
# ==============================================================================

data "aws_iam_policy_document" "aws_lb_controller_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    # Parameterized Namespace and Service Account
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.lb_controller_namespace}:${var.lb_controller_service_account}"]
    }

    # Security Best Practice: Validate the Audience
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_lb_controller" {
  name               = "${local.name_prefix}-lb-controller-irsa"
  assume_role_policy = data.aws_iam_policy_document.aws_lb_controller_assume.json
  tags               = local.common_tags
}