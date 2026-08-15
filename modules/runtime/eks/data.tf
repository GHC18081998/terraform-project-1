# ==============================================================================
# Account & Region Context
# ==============================================================================
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ==============================================================================
# IAM Trust Policies (Assume Role Documents)
# ==============================================================================

# 1. Trust policy for the EKS Control Plane
data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# 2. Trust policy for the EKS Worker Nodes (EC2)
data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# 3. Generic Trust policy for Kubernetes Service Accounts (OIDC / IRSA)
# Required for Addons (VPC CNI, EBS CSI, Load Balancer Controller, etc.)

data "aws_iam_policy_document" "oidc_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      # coalesce prevents "Null value found in list" during 'terraform validate'
      identifiers = [coalesce(var.oidc_provider_arn, "arn:aws:iam::000000000000:oidc-provider/placeholder")]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_extract}:sub"
      values   = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_extract}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}