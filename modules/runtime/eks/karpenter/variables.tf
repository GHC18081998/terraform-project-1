# ==============================================================================
# Karpenter Module Variables
# ==============================================================================

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_version" {
  description = "EKS cluster Kubernetes version"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider (without https://)"
  type        = string
}

# NOTE: region and account_id removed in favor of data sources
# (data.aws_region.current & data.aws_caller_identity.current) to prevent redundancy.

variable "karpenter_version" {
  description = "Karpenter Helm chart version (e.g., '1.2.0')"
  type        = string
  default     = null # Best practice: enforce explicit version declaration
}

variable "node_security_group_id" {
  description = "Security group ID for nodes"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Karpenter nodes"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting node volumes"
  type        = string
}

variable "launch_template_name" {
  description = "Name of the launch template for Karpenter nodes"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (e.g., prod, test)"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to Karpenter resources"
  type        = map(string)
  default     = {}
}

variable "interruption_queue_enabled" {
  description = "Enable SQS queue for node interruption handling"
  type        = bool
  default     = true
}

variable "node_pools" {
  description = "Map of Karpenter node pool configurations"
  type = map(object({
    instance_families    = list(string)
    instance_sizes       = list(string)
    capacity_types       = list(string)
    arch                 = list(string)
    ami_family           = string
    min_cpu              = string
    max_cpu              = string
    min_memory           = string
    max_memory           = string
    labels               = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
    consolidation_policy = string
    expire_after         = string
  }))
  default = {}
}

variable "oidc_client_id_list" {
  description = "List of client IDs for the OIDC provider"
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "karpenter_namespace" {
  description = "Kubernetes namespace for Karpenter"
  type        = string
  default     = "karpenter"
}

variable "karpenter_service_account" {
  description = "Service account name for Karpenter"
  type        = string
  default     = "karpenter"
}

variable "managed_by_tag" {
  description = "Value for the ManagedBy tag"
  type        = string
  default     = "Terraform"
}

# ==============================================================================
# Karpenter Node Pool Defaults & SQS Settings (REQUIRED BY LOCALS/SQS.TF)
# ==============================================================================

variable "default_node_pool_instance_families" {
  type    = list(string)
  default = ["m5", "m6i", "c5", "c6i", "r5", "r6i"]
}

variable "default_node_pool_instance_sizes" {
  type    = list(string)
  default = ["large", "xlarge", "2xlarge"]
}

variable "default_node_pool_capacity_types" {
  type    = list(string)
  default = ["on-demand", "spot"]
}

variable "default_node_pool_arch" {
  type    = list(string)
  default = ["amd64"]
}

variable "default_node_pool_ami_family" {
  type    = string
  default = "AL2023"
}

variable "default_node_pool_min_cpu" {
  type    = string
  default = "2"
}

variable "default_node_pool_max_cpu" {
  type    = string
  default = "1000"
}

variable "default_node_pool_min_memory" {
  type    = string
  default = "4Gi"
}

variable "default_node_pool_max_memory" {
  type    = string
  default = "1000Gi"
}

variable "default_node_pool_labels" {
  type    = map(string)
  default = {}
}

variable "default_node_pool_taints" {
  type    = list(any)
  default = []
}

variable "default_node_pool_consolidation_policy" {
  type    = string
  default = "WhenUnderutilized"
}

variable "default_node_pool_expire_after" {
  type    = string
  default = "720h"
}

variable "enable_spot_termination_handling" {
  description = "Enable SQS queue for spot instance termination notices"
  type        = bool
  default     = true
}

variable "sqs_queue_name_suffix" {
  description = "Suffix for the Karpenter SQS interruption queue"
  type        = string
  default     = "karpenter-interruption-queue"
}

variable "sqs_message_retention_seconds" {
  description = "Message retention in seconds for the SQS queue"
  type        = number
  default     = 300
}

# ==============================================================================
# Karpenter Helm Chart Variables
# ==============================================================================

variable "enable_karpenter" {
  description = "Toggle to enable/disable Karpenter"
  type        = bool
  default     = true
}

variable "karpenter_helm_release_name" {
  description = "Name of the Karpenter Helm release"
  type        = string
  default     = "karpenter"
}

variable "karpenter_helm_repository" {
  description = "Helm chart repository for Karpenter"
  type        = string
  default     = "oci://public.ecr.aws/karpenter"
}

variable "karpenter_helm_chart_name" {
  description = "Helm chart name for Karpenter"
  type        = string
  default     = "karpenter"
}

# ==============================================================================
# Karpenter EC2 NodeClass Variables
# ==============================================================================

variable "ec2_node_class_api_version" {
  description = "API version for the Karpenter EC2NodeClass"
  type        = string
  default     = "karpenter.k8s.aws/v1"
}

variable "ec2_node_class_kind" {
  description = "Kind for the Karpenter EC2NodeClass"
  type        = string
  default     = "EC2NodeClass"
}

variable "ec2_node_class_name" {
  description = "Name for the default Karpenter EC2NodeClass"
  type        = string
  default     = "default"
}

variable "node_class_ami_family" {
  description = "AMI family for the Karpenter EC2NodeClass (e.g., AL2, AL2023, Bottlerocket)"
  type        = string
  default     = "AL2023"
}

variable "karpenter_discovery_tag_key" {
  description = "Tag key used by Karpenter to discover subnets and security groups"
  type        = string
  default     = "karpenter.sh/discovery"
}

# ==============================================================================
# Karpenter NodePool Variables
# ==============================================================================

variable "node_pool_api_version" {
  description = "API version for the Karpenter NodePool"
  type        = string
  default     = "karpenter.sh/v1"
}

variable "node_pool_kind" {
  description = "Kind for the Karpenter NodePool"
  type        = string
  default     = "NodePool"
}

variable "node_pool_name" {
  description = "Name for the Karpenter NodePool"
  type        = string
  default     = "default"
}

variable "node_pool_capacity_types" {
  description = "Capacity types for the NodePool (e.g., on-demand, spot)"
  type        = list(string)
  default     = ["on-demand", "spot"]
}

variable "node_pool_architectures" {
  description = "Architectures for the NodePool (e.g., amd64, arm64)"
  type        = list(string)
  default     = ["amd64"]
}

variable "node_pool_instance_categories" {
  description = "Instance categories for the NodePool (e.g., c, m, r)"
  type        = list(string)
  default     = ["c", "m", "r"]
}

variable "node_pool_limit_cpu" {
  description = "CPU limit for the NodePool"
  type        = string
  default     = "1000"
}

variable "node_pool_consolidation_policy" {
  description = "Consolidation policy for the NodePool (WhenUnderutilized or WhenEmpty)"
  type        = string
  default     = "WhenUnderutilized"
}

variable "node_pool_consolidate_after" {
  description = "Time to wait before consolidating nodes (required if policy is WhenEmpty, e.g., 10m)"
  type        = string
  default     = "10m"
}

variable "node_pool_budget_nodes" {
  description = "Disruption budget for nodes (e.g., 10% or 2)"
  type        = string
  default     = "10%"
}
