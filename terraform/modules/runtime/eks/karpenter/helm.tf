# ==============================================================================
# Karpenter Helm Release (Streamlined & Parameterized)
# ==============================================================================
resource "helm_release" "karpenter" {
  count            = var.enable_karpenter ? 1 : 0
  namespace        = local.namespace
  create_namespace = true
  name             = var.karpenter_helm_release_name
  repository       = var.karpenter_helm_repository
  chart            = var.karpenter_helm_chart_name
  version          = var.karpenter_version

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.controller[0].arn
  }

  set {
    name  = "settings.interruptionQueue"
    # Safe evaluation prevents index errors if the queue count is 0
    value = var.enable_spot_termination_handling ? try(aws_sqs_queue.interruption[0].name, "") : ""
  }

  depends_on = [
    aws_iam_role_policy.controller
  ]
}