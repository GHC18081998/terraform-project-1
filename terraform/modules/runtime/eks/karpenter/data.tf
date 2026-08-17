# ==============================================================================
# AWS Account & Region Context Data Sources
# ==============================================================================
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

# ==============================================================================
# VPC & Subnet Data Sources
# ==============================================================================
data "aws_subnets" "karpenter" {
  filter {
    name   = "subnet-id"
    values = var.private_subnet_ids
  }
}

# ==============================================================================
# EKS Optimized AMI Lookup (SSM Parameter Store)
# ==============================================================================
data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${var.cluster_version}/amazon-linux-2/recommended/image_id"
}

# ============================================================
# Karpenter Controller IAM Data Sources
# ============================================================
data "aws_iam_policy_document" "controller_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "")}:aud"
      values   = var.oidc_client_id_list
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "")}:sub"
      values   = ["system:serviceaccount:${var.karpenter_namespace}:${var.karpenter_service_account}"]
    }
  }
}

data "aws_iam_policy_document" "controller_policy" {
  # 1. Standard Read & Creation Permissions
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateTags",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
      "ec2:RunInstances",
      "pricing:GetProducts",
      "ssm:GetParameter",
      "eks:DescribeCluster"
    ]
    resources = ["*"]
  }

  # 2. SECURE TERMINATION - Only allow Karpenter to delete its OWN nodes
  statement {
    effect = "Allow"
    actions = [
      "ec2:TerminateInstances",
      "ec2:DeleteLaunchTemplate"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  # 3. Missing IAM Permissions required for Karpenter to bind IAM to nodes
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
      "iam:CreateInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:TagInstanceProfile"
    ]
    resources = [
      try(aws_iam_role.node[0].arn, ""),
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
    ]
  }

  # 4. Safely handle the SQS conditional without generating 'null'
  dynamic "statement" {
    for_each = var.enable_spot_termination_handling ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage"
      ]
      resources = [aws_sqs_queue.interruption[0].arn]
    }
  }
}
