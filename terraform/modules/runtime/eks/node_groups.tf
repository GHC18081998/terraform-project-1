resource "aws_eks_node_group" "workers" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-${each.key}-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids

  # Parameterized fallbacks instead of hardcoded strings
  ami_type       = lookup(each.value, "ami_type", var.default_ami_type)
  capacity_type  = lookup(each.value, "capacity_type", var.default_capacity_type)
  instance_types = lookup(each.value, "instance_types", var.default_instance_types)

  launch_template {
    id      = aws_launch_template.nodes.id
    version = aws_launch_template.nodes.latest_version
  }

  scaling_config {
    desired_size = lookup(each.value, "desired_size", var.default_desired_size)
    min_size     = lookup(each.value, "min_size", var.default_min_size)
    max_size     = lookup(each.value, "max_size", var.default_max_size)
  }

  labels = lookup(each.value, "labels", var.default_labels)

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-${each.key}-node-group"
    }
  )

  # REQUIRED: Protects Kubernetes Autoscaler from Terraform state overrides.
  # Note: Variables are strictly forbidden inside lifecycle blocks by Terraform Core.
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # REQUIRED: Prevents IAM race conditions during cluster creation
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_AmazonSSMManagedInstanceCore
  ]
}