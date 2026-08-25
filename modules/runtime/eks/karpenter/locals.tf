locals {
  name_prefix               = var.cluster_name
  namespace                 = var.karpenter_namespace
  karpenter_namespace       = var.karpenter_namespace
  karpenter_service_account = var.karpenter_service_account

  common_tags = merge(
    var.tags,
    {
      "karpenter.sh/discovery" = var.cluster_name
      "ManagedBy"              = var.managed_by_tag
    }
  )

  # Default node pool fallback map driven entirely by variables
  default_node_pools = length(var.node_pools) == 0 ? {
    "default" = {
      instance_families    = var.default_node_pool_instance_families
      instance_sizes       = var.default_node_pool_instance_sizes
      capacity_types       = var.default_node_pool_capacity_types
      arch                 = var.default_node_pool_arch
      ami_family           = var.default_node_pool_ami_family
      min_cpu              = var.default_node_pool_min_cpu
      max_cpu              = var.default_node_pool_max_cpu
      min_memory           = var.default_node_pool_min_memory
      max_memory           = var.default_node_pool_max_memory
      labels               = var.default_node_pool_labels
      taints               = var.default_node_pool_taints
      consolidation_policy = var.default_node_pool_consolidation_policy
      expire_after         = var.default_node_pool_expire_after
    }
  } : var.node_pools

  node_pools = local.default_node_pools
}