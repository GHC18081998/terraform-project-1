# ==============================================================================
# AWS Load Balancer Controller IAM Policy Document
# ==============================================================================

data "aws_iam_policy_document" "lb_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  # EC2 - CreateTags for Load Balancers
  statement {
    sid       = "CreateTags"
    effect    = "Allow"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:*:*:security-group/*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateSecurityGroup"]
    }
    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  # EC2 - CreateTags for existing resources
  statement {
    sid       = "CreateTagsExisting"
    effect    = "Allow"
    actions   = ["ec2:CreateTags", "ec2:DeleteTags"]
    resources = ["arn:aws:ec2:*:*:security-group/*"]
    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["true"]
    }
    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  # EC2 - Read permissions
  statement {
    sid    = "EC2ReadPermissions"
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeCoipPools",
      "ec2:DescribeInstances",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeVpcs",
      "ec2:GetCoipPoolUsage",
    ]
    resources = ["*"]
  }

  # Elastic Load Balancing - Core Permissions
  statement {
    sid    = "ELBReadPermissions"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
    ]
    resources = ["*"]
  }

  # Elastic Load Balancing - Create/Modify
  statement {
    sid    = "ELBWritePermissions"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebAcl",
    ]
    resources = ["*"]
  }

  # Cognito - User Pool authentication
  statement {
    sid       = "CognitoPermissions"
    effect    = "Allow"
    actions   = ["cognito-idp:DescribeUserPoolClient"]
    resources = ["*"]
  }

  # ACM - Certificate Management
  statement {
    sid       = "ACMPermissions"
    effect    = "Allow"
    actions   = ["acm:DescribeCertificate", "acm:ListCertificates"]
    resources = ["*"]
  }

  # IAM - Create Service Linked Role
  statement {
    sid       = "IAMPermissions"
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.amazonaws.com"]
    }
  }

  # Shield - Advanced Protection (conditional)
  dynamic "statement" {
    for_each = var.enable_shield ? [1] : []
    content {
      sid       = "ShieldPermissions"
      effect    = "Allow"
      actions   = [
        "shield:CreateProtection",
        "shield:DeleteProtection",
        "shield:DescribeProtection",
        "shield:GetSubscriptionState",
        "shield:ListProtections",
      ]
      resources = ["*"]
    }
  }

  # WAF - Classic Support (conditional)
  dynamic "statement" {
    for_each = var.enable_waf ? [1] : []
    content {
      sid       = "WAFPermissions"
      effect    = "Allow"
      actions   = [
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL",
        "waf-regional:GetWebACL",
        "waf-regional:GetWebACLForResource",
        "waf-regional:ListResourcesForWebACL",
        "waf-regional:ListWebACLs",
      ]
      resources = ["*"]
    }
  }

  # WAFv2 - Support (conditional)
  dynamic "statement" {
    for_each = var.enable_wafv2 ? [1] : []
    content {
      sid       = "WAFv2Permissions"
      effect    = "Allow"
      actions   = [
        "wafv2:AssociateWebACL",
        "wafv2:DisassociateWebACL",
        "wafv2:GetWebACL",
        "wafv2:GetWebACLForResource",
        "wafv2:ListResourcesForWebACL",
        "wafv2:ListWebACLs",
      ]
      resources = ["*"]
    }
  }

  # Route53 - DNS Management
  statement {
    sid       = "Route53Permissions"
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  # Tags - Resource Groups
  statement {
    sid       = "TagsPermissions"
    effect    = "Allow"
    actions   = ["tag:GetResources"]
    resources = ["*"]
  }
}
