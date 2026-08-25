# ==============================================================================
# AWS Load Balancer Controller Outputs
# Location: environments/.../modules/runtime/eks/output.tf
# ==============================================================================

#-------------------------------------------------------
# IAM Outputs
#-------------------------------------------------------
output "lb_controller_iam_role_arn" {
  description = "ARN of the IAM role for the Load Balancer Controller"
  value       = try(aws_iam_role.lb_controller[0].arn, null)
}

output "lb_controller_iam_role_name" {
  description = "Name of the IAM role for the Load Balancer Controller"
  value       = try(aws_iam_role.lb_controller[0].name, null)
}

output "lb_controller_iam_policy_arn" {
  description = "ARN of the IAM policy for the Load Balancer Controller"
  value       = try(aws_iam_policy.lb_controller[0].arn, null)
}

output "lb_controller_iam_policy_name" {
  description = "Name of the IAM policy for the Load Balancer Controller"
  value       = try(aws_iam_policy.lb_controller[0].name, null)
}

#-------------------------------------------------------
# Helm Release Outputs
#-------------------------------------------------------
output "lb_controller_helm_release_name" {
  description = "Name of the Helm release"
  value       = try(helm_release.lb_controller[0].name, null)
}

output "lb_controller_helm_release_namespace" {
  description = "Namespace of the Helm release"
  value       = try(helm_release.lb_controller[0].namespace, null)
}

output "lb_controller_helm_release_version" {
  description = "Version of the deployed Helm chart"
  value       = try(helm_release.lb_controller[0].version, null)
}

output "lb_controller_helm_release_status" {
  description = "Status of the Helm release"
  value       = try(helm_release.lb_controller[0].status, null)
}

#-------------------------------------------------------
# Service Account Outputs (Helm-managed)
#-------------------------------------------------------
output "lb_controller_service_account_name" {
  description = "Name of the Kubernetes service account used by the LB Controller"
  value       = var.lb_controller_service_account
}

output "lb_controller_service_account_namespace" {
  description = "Namespace of the Kubernetes service account"
  value       = var.lb_controller_namespace
}

#-------------------------------------------------------
# OIDC Outputs
#-------------------------------------------------------
output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = local.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider"
  value       = local.oidc_provider_url
}

#-------------------------------------------------------
# Cluster & Account Context Outputs
#-------------------------------------------------------
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.cluster_name
}

output "aws_region" {
  description = "AWS region"
  value       = local.aws_region
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = local.account_id
}
