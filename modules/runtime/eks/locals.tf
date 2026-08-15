locals {
  # ============================================================================
  # Naming & Tagging
  # ============================================================================
  cluster_name = var.cluster_name
  name_prefix  = "${var.environment}-${var.cluster_name}"
  
  common_tags = merge(
    {
      Environment                                   = var.environment
      ManagedBy                                     = var.managed_by_tag
      "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    },
    var.extra_tags
  )

  # Tags strictly required for Karpenter auto-scaling discovery
  karpenter_tags = merge(
    local.common_tags,
    {
      "karpenter.sh/discovery" = local.cluster_name
    }
  )

  # ============================================================================
  # Node Group Configs
  # ============================================================================
  # Parameterized defaults to keep your .tfvars file clean
  node_group_defaults = {
    ami_type       = var.default_ami_type
    capacity_type  = var.default_capacity_type
    disk_size_gb   = var.default_disk_size_gb
    instance_types = var.default_instance_types
    labels         = var.default_labels
    taints         = var.default_taints
    min_size       = var.default_min_size
    max_size       = var.default_max_size
    desired_size   = var.default_desired_size
  }

  # ============================================================================
  # IAM & OIDC (IRSA)
  # ============================================================================
  # Strips the protocol to format the URL correctly for IAM trust policies.
  # (Note: "https://" is an AWS API structural requirement, not a config value)
  irsa_oidc_provider_url = replace(
    aws_eks_cluster.main.identity[0].oidc[0].issuer,
    "https://",
    ""
  )

  # ============================================================================
  # EKS Addons
  # ============================================================================
  addons = {
    coredns = {
      enabled = var.enable_coredns
      version = var.coredns_version
    }
    vpc_cni = {
      enabled = var.enable_vpc_cni
      version = var.vpc_cni_version
    }
    kube_proxy = {
      enabled = var.enable_kube_proxy
      version = var.kube_proxy_version
    }
    ebs_csi_driver = {
      enabled = var.enable_ebs_csi_driver
      version = var.ebs_csi_driver_version
    }
  }
}