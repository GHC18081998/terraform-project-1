resource "aws_eks_addon" "addons" {
  for_each = var.eks_addons

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.key
  addon_version               = try(each.value.version, null)
  service_account_role_arn    = try(each.value.service_account_role_arn, null)
  configuration_values        = try(each.value.configuration_values, null)
  resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, "OVERWRITE")
  resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE")

  tags = merge(local.common_tags, try(each.value.tags, {}))

  # Ensures node groups exist before addons like CoreDNS/CSI drivers attempt to start
  depends_on = [
    aws_eks_node_group.workers  # Fixed from aws_eks_node_group.main
  ]
}