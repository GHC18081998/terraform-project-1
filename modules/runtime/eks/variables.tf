# ==============================================================================
# 1. Core Cluster & Environment
# ==============================================================================
variable "environment" {
  description = "Environment name (e.g., prod, test)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

# ==============================================================================
# 2. Networking
# ==============================================================================
variable "vpc_id" {
  description = "VPC ID where the cluster and nodes will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS worker nodes and control plane"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the cluster endpoint"
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDRs that can access the public cluster endpoint"
  type        = list(string)
  default     = []
}

variable "cluster_service_ipv4_cidr" {
  description = "CIDR block for the Kubernetes service network"
  type        = string
  default     = "172.20.0.0/16"
}

# ==============================================================================
# 3. Observability & Logging
# ==============================================================================
variable "cluster_enabled_log_types" {
  description = "List of control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_days" {
  description = "Number of days to retain CloudWatch logs for the cluster"
  type        = number
  default     = 90
}

# ==============================================================================
# 4. Compute & Node Group Fallbacks
# ==============================================================================
variable "node_groups" {
  description = "Map of EKS node group configurations"
  type        = any
  default     = {}
}

variable "default_ami_type" {
  description = "Default AMI type for node groups"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "default_capacity_type" {
  description = "Default capacity type for node groups (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "default_instance_types" {
  description = "Default list of instance types for node groups"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "default_disk_size_gb" {
  description = "Default disk size in GB for worker nodes"
  type        = number
  default     = 50
}

variable "default_min_size" {
  description = "Default minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "default_max_size" {
  description = "Default maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "default_desired_size" {
  description = "Default desired number of worker nodes"
  type        = number
  default     = 2
}

variable "default_labels" {
  description = "Default Kubernetes labels to apply to the nodes"
  type        = map(string)
  default     = {}
}

variable "default_taints" {
  description = "Default Kubernetes taints to apply to the nodes"
  type        = any
  default     = []
}

# ==============================================================
# 5. Security Groups & Network Rules
# ==============================================================
variable "sg_any_port" {
  type    = number
  default = 0
}

variable "sg_any_protocol" {
  type    = string
  default = "-1"
}

variable "sg_tcp_protocol" {
  type    = string
  default = "tcp"
}

variable "cluster_egress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "node_egress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "cluster_api_port" {
  type    = number
  default = 443
}

variable "kubelet_port" {
  type    = number
  default = 10250
}

variable "ephemeral_port_start" {
  type    = number
  default = 1025
}

variable "ephemeral_port_end" {
  type    = number
  default = 65535
}

variable "node_security_group_additional_rules" {
  description = "Additional security group rules for the node security group"
  type        = any
  default     = {}
}

variable "cluster_additional_security_group_ids" {
  description = "Additional security group IDs to attach to the cluster"
  type        = list(string)
  default     = []
}

# ==============================================================================
# 6. IAM, OIDC & KMS
# ==============================================================================
variable "aws_auth_roles" {
  description = "List of IAM roles to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_users" {
  description = "List of IAM users to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "kms_key_administrators" {
  description = "List of IAM ARNs that can administer the KMS key"
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "Optional custom KMS key ARN. If null or empty, a key will be created."
  type        = string
  default     = null
}

variable "kms_deletion_window" {
  description = "Duration in days after which the KMS key is deleted"
  type        = number
  default     = 7
}

variable "kms_enable_rotation" {
  description = "Specifies whether key rotation is enabled"
  type        = bool
  default     = true
}

variable "oidc_client_id_list" {
  description = "List of client IDs (audiences) for the OIDC provider"
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

# ==============================================================================
# 7. Addons & Feature Toggles
# ==============================================================================
variable "enable_karpenter" {
  type    = bool
  default = true
}

variable "enable_cluster_autoscaler" {
  type    = bool
  default = false
}

variable "enable_aws_load_balancer_controller" {
  type    = bool
  default = true
}

variable "enable_external_dns" {
  type    = bool
  default = true
}

variable "enable_cert_manager" {
  type    = bool
  default = true
}

variable "enable_metrics_server" {
  type    = bool
  default = true
}

variable "enable_aws_node_termination_handler" {
  type    = bool
  default = true
}

variable "enable_container_insights" {
  type    = bool
  default = true
}

variable "enable_prometheus" {
  type    = bool
  default = true
}

variable "enable_ebs_csi_driver" {
  type    = bool
  default = true
}

variable "enable_efs_csi_driver" {
  type    = bool
  default = false
}

variable "enable_vpc_cni" {
  type    = bool
  default = true
}

variable "enable_coredns" {
  type    = bool
  default = true
}

variable "enable_kube_proxy" {
  type    = bool
  default = true
}

variable "karpenter_version" {
  description = "Karpenter Helm chart version"
  type        = string
  default     = null
}

variable "coredns_version" {
  type    = string
  default = null
}

variable "vpc_cni_version" {
  type    = string
  default = null
}

variable "kube_proxy_version" {
  type    = string
  default = null
}

variable "ebs_csi_driver_version" {
  type    = string
  default = null
}

variable "eks_addons" {
  description = "Map of native EKS addons configuration"
  type = map(object({
    version                  = optional(string)
    service_account_role_arn = optional(string)
  }))
  default = {}
}

# ==============================================================================
# 8. External Integrations & Tagging
# ==============================================================================
variable "route53_zone_id" {
  description = "Route53 hosted zone ID for ExternalDNS"
  type        = string
  default     = ""
}

variable "route53_zone_name" {
  description = "Route53 hosted zone name"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "extra_tags" {
  description = "Additional tags to append to module resources"
  type        = map(string)
  default     = {}
}

variable "managed_by_tag" {
  description = "Value for the ManagedBy tag"
  type        = string
  default     = "Terraform"
}

# ==============================================================================
# 9. IRSA, Addon Namespaces & Launch Template Extras
# ==============================================================================
variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
  default     = null
}

variable "oidc_provider_extract" {
  description = "Extracted OIDC provider URL path for IAM trust policies"
  type        = string
  default     = ""
}

variable "service_account_namespace" {
  description = "Kubernetes namespace for general service accounts"
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "Kubernetes service account name"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "ebs_csi_namespace" {
  description = "Namespace for EBS CSI driver"
  type        = string
  default     = "kube-system"
}

variable "ebs_csi_service_account" {
  description = "Service account name for EBS CSI driver"
  type        = string
  default     = "ebs-csi-controller-sa"
}

variable "lb_controller_namespace" {
  description = "Namespace for AWS Load Balancer Controller"
  type        = string
  default     = "kube-system"
}

variable "lb_controller_service_account" {
  description = "Service account name for AWS Load Balancer Controller"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "node_volume_device_name" {
  description = "Device name for the worker node root volume"
  type        = string
  default     = "/dev/xvda"
}

variable "node_volume_size" {
  description = "Root disk size in GB for worker nodes"
  type        = number
  default     = 50
}

variable "node_volume_type" {
  description = "Volume type for worker nodes"
  type        = string
  default     = "gp3"
}

variable "enable_node_volume_encryption" {
  description = "Enable encryption on worker node root volumes"
  type        = bool
  default     = true
}

variable "cluster_kms_key_arn" {
  description = "KMS key ARN used for worker node volume encryption"
  type        = string
  default     = null
}

variable "node_volume_delete_on_termination" {
  description = "Whether the node root volume deletes on termination"
  type        = bool
  default     = true
}

variable "node_pools" {
  description = "Karpenter node pool configurations"
  type        = any
  default     = {}
}

# ==============================================================================
# Cluster Encryption Config
# ==============================================================================
variable "cluster_encryption_resources" {
  description = "List of Kubernetes cluster resources to encrypt (e.g., secrets)"
  type        = list(string)
  default     = ["secrets"]
}