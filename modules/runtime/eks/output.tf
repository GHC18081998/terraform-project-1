# ==============================================================================
# 1. Core Cluster Outputs
# ==============================================================================
output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
  sensitive   = true
}

output "cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = aws_eks_cluster.main.version
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_primary_security_group_id" {
  description = "Cluster primary security group ID"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

# ==============================================================================
# 2. Security Groups & IAM Roles
# ==============================================================================
output "cluster_security_group_id" {
  description = "Security group ID of the cluster control plane"
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "Security group ID for cluster nodes"
  value       = aws_security_group.nodes.id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "node_group_iam_role_arn" {
  description = "IAM role ARN for EKS node groups"
  value       = try(aws_eks_node_group.workers["system"].node_role_arn, "")
}

output "node_group_iam_role_name" {
  description = "IAM role name for EKS node groups"
  value       = ""
}

# ==============================================================================
# 3. OIDC & IRSA Roles
# ==============================================================================
output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.url
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = null
}

output "external_dns_role_arn" {
  description = "IAM role ARN for ExternalDNS"
  value       = null
}

output "cert_manager_role_arn" {
  description = "IAM role ARN for cert-manager"
  value       = null
}

output "ebs_csi_driver_role_arn" {
  description = "IAM role ARN for EBS CSI driver"
  value       = null
}

# ==============================================================================
# 4. KMS Keys
# ==============================================================================
output "kms_key_arn" {
  description = "ARN of the KMS key for EKS encryption"
  value       = aws_kms_key.eks.arn
}

output "kms_key_id" {
  description = "ID of the KMS key for EKS encryption"
  value       = aws_kms_key.eks.key_id
}

output "eks_secrets_kms_key_arn" {
  description = "ARN of the KMS key for EKS secrets"
  value       = aws_kms_key.eks.arn
}

output "cloudwatch_kms_key_arn" {
  description = "ARN of the KMS key for CloudWatch logs"
  value       = aws_kms_key.eks.arn
}

# ==============================================================================
# 5. Karpenter Outputs
# ==============================================================================
output "karpenter_node_instance_profile_name" {
  description = "Instance profile name used by Karpenter nodes"
  value       = var.enable_karpenter ? try(module.karpenter[0].node_instance_profile_name, null) : null
}

output "karpenter_irsa_arn" {
  description = "IRSA ARN for Karpenter"
  value       = var.enable_karpenter ? try(module.karpenter[0].irsa_arn, null) : null
}

# ==============================================================================
# 6. Node Groups & Operations
# ==============================================================================
output "node_groups" {
  description = "Map of node group resources"
  value = {
    for k, v in aws_eks_node_group.workers : k => {
      arn    = v.arn
      status = v.status
    }
  }
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${local.cluster_name}"
}