resource "aws_launch_template" "nodes" {
  name_prefix            = "${local.name_prefix}-node-lt-"
  description            = "Custom launch template for EKS managed node group"
  update_default_version = true

  vpc_security_group_ids = [aws_security_group.nodes.id]

  block_device_mappings {
    device_name = var.node_volume_device_name

    ebs {
      volume_size           = var.node_volume_size
      volume_type           = var.node_volume_type
      encrypted             = var.enable_node_volume_encryption
      
      # Dynamically use the KMS key if encryption is enabled
      kms_key_id            = var.enable_node_volume_encryption ? var.cluster_kms_key_arn : null
      
      delete_on_termination = var.node_volume_delete_on_termination
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.common_tags, { Name = "${local.name_prefix}-managed-node" })
  }

  lifecycle {
    create_before_destroy = true
  }
}