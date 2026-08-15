# ==============================================================================
# Karpenter NodePool (Fully Dynamic kubectl Manifest)
# ==============================================================================
resource "kubectl_manifest" "karpenter_node_pool" {
  for_each = var.node_pools

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: ${each.key}
    spec:
      template:
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: ${var.ec2_node_class_name}

          requirements:
            - key: "karpenter.sh/capacity-type"
              operator: In
              values: ${jsonencode(each.value.capacity_types)}
            - key: "kubernetes.io/arch"
              operator: In
              values: ${jsonencode(each.value.arch)}
            - key: "karpenter.k8s.aws/instance-family"
              operator: In
              values: ${jsonencode(each.value.instance_families)}
            - key: "karpenter.k8s.aws/instance-size"
              operator: In
              values: ${jsonencode(each.value.instance_sizes)}

          labels:
%{for k, v in each.value.labels ~}
            ${k}: "${v}"
%{endfor ~}

      disruption:
        # Automatically maps legacy v1beta1 'WhenUnderutilized' to v1 supported 'WhenEmptyOrUnderutilized'
        consolidationPolicy: ${each.value.consolidation_policy == "WhenUnderutilized" ? "WhenEmptyOrUnderutilized" : each.value.consolidation_policy}
        consolidateAfter: 30s
        expireAfter: ${each.value.expire_after}
  YAML

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}