# ==============================================================================
# Amazon EKS Cluster Resource
# ==============================================================================
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  # Conditionally generate encryption_config only if a KMS Key ARN is provided
  dynamic "encryption_config" {
    for_each = var.kms_key_arn != null && var.kms_key_arn != "" ? [1] : []
    content {
      provider {
        key_arn = var.kms_key_arn
      }
      resources = var.cluster_encryption_resources
    }
  }

  enabled_cluster_log_types = var.cluster_enabled_log_types

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_cloudwatch_log_group.eks
  ]

  tags = local.common_tags
}

# ==============================================================================
# Karpenter Module Orchestration (inside ../../modules/runtime/eks/cluster.tf)
# ==============================================================================
module "karpenter" {
  count  = var.enable_karpenter ? 1 : 0
  source = "./karpenter"

  cluster_name      = local.cluster_name
  cluster_endpoint  = aws_eks_cluster.main.endpoint
  cluster_version   = var.cluster_version
  oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn
  oidc_provider_url = aws_iam_openid_connect_provider.eks.url

  node_security_group_id = aws_security_group.nodes.id
  private_subnet_ids     = var.private_subnet_ids
  kms_key_arn            = aws_kms_key.eks.arn
  karpenter_version      = var.karpenter_version
  environment            = var.environment
  tags                   = local.common_tags
  node_pools             = var.node_pools

  depends_on = [
    aws_eks_node_group.workers,
  ]
}