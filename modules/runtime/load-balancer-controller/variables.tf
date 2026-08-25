# ==============================================================================
# AWS Load Balancer Controller - Helm & Deployment Variables
# ==============================================================================

variable "lb_controller_helm_release_name" {
  description = "Helm release name for the LB Controller"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "lb_controller_helm_repo" {
  description = "Helm repository URL for the LB Controller"
  type        = string
  default     = "https://aws.github.io/eks-charts"
}

variable "lb_controller_helm_chart" {
  description = "Helm chart name for the LB Controller"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "lb_controller_chart_version" {
  description = "Version of the LB Controller Helm chart"
  type        = string
  default     = "1.7.1"
}

variable "lb_controller_namespace" {
  description = "Kubernetes namespace to deploy the LB Controller into"
  type        = string
  default     = "kube-system"
}

variable "lb_controller_image_tag" {
  description = "Docker image tag for the LB Controller"
  type        = string
  default     = "v2.7.1"
}

variable "lb_controller_replica_count" {
  description = "Number of replicas for the LB Controller"
  type        = number
  default     = 2
}

# --- Helm Lifecycle Settings ---

variable "lb_controller_helm_wait" {
  description = "Wait for Helm release to be fully deployed"
  type        = bool
  default     = true
}

variable "lb_controller_helm_wait_for_jobs" {
  description = "Wait for Helm jobs to complete"
  type        = bool
  default     = true
}

variable "lb_controller_helm_timeout" {
  description = "Timeout in seconds for Helm deployment"
  type        = number
  default     = 300
}

variable "lb_controller_helm_cleanup_on_fail" {
  description = "Clean up resources if Helm deployment fails"
  type        = bool
  default     = true
}

# --- Compute Resources ---

variable "lb_controller_cpu_request" {
  description = "Requested CPU for LB Controller pods"
  type        = string
  default     = "100m"
}

variable "lb_controller_memory_request" {
  description = "Requested memory for LB Controller pods"
  type        = string
  default     = "128Mi"
}

variable "lb_controller_cpu_limit" {
  description = "CPU limit for LB Controller pods"
  type        = string
  default     = "200m"
}

variable "lb_controller_memory_limit" {
  description = "Memory limit for LB Controller pods"
  type        = string
  default     = "256Mi"
}

variable "lb_controller_pdb_max_unavailable" {
  description = "Max unavailable pods for the Pod Disruption Budget"
  type        = number
  default     = 1
}

# --- Pod Affinity ---

variable "lb_controller_pod_anti_affinity_weight" {
  description = "Weight applied to pod anti-affinity rule"
  type        = number
  default     = 100
}

variable "lb_controller_topology_key" {
  description = "Topology key for pod anti-affinity"
  type        = string
  default     = "kubernetes.io/hostname"
}

variable "lb_controller_app_name_label_key" {
  description = "Label key used in pod anti-affinity selection"
  type        = string
  default     = "app.kubernetes.io/name"
}

variable "lb_controller_app_name_label_operator" {
  description = "Operator used in pod anti-affinity match expressions"
  type        = string
  default     = "In"
}

variable "lb_controller_app_name_label_value" {
  description = "Value to match for pod anti-affinity"
  type        = string
  default     = "aws-load-balancer-controller"
}

# --- Service Account & IAM Settings ---

variable "lb_controller_service_account" {
  description = "Name of the Kubernetes Service Account for the LB Controller"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "lb_controller_service_account_create" {
  description = "Let Helm create the ServiceAccount"
  type        = bool
  default     = true
}

variable "lb_controller_use_sts_regional_endpoints" {
  description = "Use regional STS endpoints for IRSA"
  type        = bool
  default     = true
}

variable "lb_controller_iam_role_suffix" {
  description = "Suffix for the IAM Role name"
  type        = string
  default     = "lb-controller-irsa"
}

variable "lb_controller_iam_policy_suffix" {
  description = "Suffix for the IAM Policy name"
  type        = string
  default     = "lb-controller-policy"
}

variable "lb_controller_iam_role_description" {
  description = "Description for the IAM role"
  type        = string
  default     = "IAM role for AWS Load Balancer Controller"
}

variable "lb_controller_iam_policy_description" {
  description = "Description for the IAM policy"
  type        = string
  default     = "IAM policy for AWS Load Balancer Controller"
}

# --- Add-ons & Logging ---

variable "enable_waf" {
  description = "Enable WAF classic integration for ALBs"
  type        = bool
  default     = false
}

variable "enable_wafv2" {
  description = "Enable WAFv2 integration for ALBs"
  type        = bool
  default     = true
}

variable "enable_shield" {
  description = "Enable AWS Shield Advanced integration"
  type        = bool
  default     = false
}

variable "lb_controller_log_level" {
  description = "Log level for the LB Controller (info, debug, error)"
  type        = string
  default     = "info"
}

# ==============================================================================
# IRSA / OIDC Variables
# ==============================================================================

variable "oidc_audience" {
  description = "Audience for the OIDC provider trust relationship"
  type        = string
  default     = "sts.amazonaws.com"
}

# ==============================================================================
# Variables extracted from locals.tf
# ==============================================================================

variable "iam_role_name" {
  description = "Explicit IAM role name override"
  type        = string
  default     = ""
}

variable "iam_policy_name" {
  description = "Explicit IAM policy name override"
  type        = string
  default     = ""
}

variable "managed_by_tag" {
  description = "Value for the ManagedBy tag"
  type        = string
  default     = "Terraform"
}

variable "lb_controller_component_tag" {
  description = "Value for the Component tag"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "additional_tags" {
  description = "Additional tags to append to the module's resources"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# Core Module Variables (Required for standalone module)
# ==============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, test)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the cluster is deployed"
  type        = string
}

variable "enable_aws_load_balancer_controller" {
  description = "Feature toggle to enable/disable the LB controller"
  type        = bool
  default     = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  # No default - force the environment to pass it explicitly
}

# ==============================================================================
# OIDC Variables (Passed from the EKS cluster module)
# ==============================================================================

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider"
  type        = string
}
