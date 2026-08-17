# ==============================================================================
# Karpenter EC2NodeClass (Dynamic kubectl Manifest)
# ==============================================================================
resource "kubectl_manifest" "karpenter_node_class" {
  count     = var.enable_karpenter ? 1 : 0
  yaml_body = <<-YAML
    apiVersion: ${var.ec2_node_class_api_version}
    kind: ${var.ec2_node_class_kind}
    metadata:
      name: ${var.ec2_node_class_name}
    spec:
      amiFamily: ${var.node_class_ami_family}
      role: "${try(aws_iam_role.node[0].name, "")}"

      # REQUIRED IN v1 API: Tells Karpenter which AMIs to use
      amiSelectorTerms:
        - alias: al2023@latest

      subnetSelectorTerms:
        - tags:
            ${var.karpenter_discovery_tag_key}: "${var.cluster_name}"
      securityGroupSelectorTerms:
        - tags:
            ${var.karpenter_discovery_tag_key}: "${var.cluster_name}"
  YAML

  depends_on = [
    helm_release.karpenter,
    aws_iam_role.node
  ]
}
