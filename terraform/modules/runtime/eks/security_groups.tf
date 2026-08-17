# ==============================================================================
# Cluster Security Group
# ==============================================================================
resource "aws_security_group" "cluster" {
  name        = "${local.name_prefix}-cluster-sg"
  description = "Security group for EKS control plane"
  vpc_id      = var.vpc_id

  egress {
    from_port   = var.sg_any_port
    to_port     = var.sg_any_port
    protocol    = var.sg_any_protocol
    cidr_blocks = var.cluster_egress_cidrs
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-cluster-sg" })
}

# ==============================================================================
# Node Security Group
# ==============================================================================
resource "aws_security_group" "nodes" {
  name        = "${local.name_prefix}-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  # Self-referencing inline ingress is okay
  ingress {
    description = "Allow node-to-node communication"
    from_port   = var.sg_any_port
    to_port     = var.sg_any_port
    protocol    = var.sg_any_protocol
    self        = true
  }

  egress {
    from_port   = var.sg_any_port
    to_port     = var.sg_any_port
    protocol    = var.sg_any_protocol
    cidr_blocks = var.node_egress_cidrs
  }

  tags = merge(local.common_tags, {
    Name                                          = "${local.name_prefix}-node-sg"
    "karpenter.sh/discovery"                      = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}"   = "owned"
  })
}

# ==============================================================================
# Standalone Cross-Referencing Security Group Rules
# ==============================================================================
resource "aws_security_group_rule" "cluster_ingress_nodes_https" {
  description              = "Allow worker nodes to communicate with the cluster API server"
  type                     = "ingress"
  from_port                = var.cluster_api_port
  to_port                  = var.cluster_api_port
  protocol                 = var.sg_tcp_protocol
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "nodes_ingress_cluster_https" {
  description              = "Allow control plane communication to nodes on 443"
  type                     = "ingress"
  from_port                = var.cluster_api_port
  to_port                  = var.cluster_api_port
  protocol                 = var.sg_tcp_protocol
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.cluster.id
}

resource "aws_security_group_rule" "nodes_ingress_cluster_kubelet" {
  description              = "Allow control plane to communicate with worker node kubelet"
  type                     = "ingress"
  from_port                = var.kubelet_port
  to_port                  = var.kubelet_port
  protocol                 = var.sg_tcp_protocol
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.cluster.id
}

resource "aws_security_group_rule" "nodes_ingress_cluster_others" {
  description              = "Allow control plane traffic to worker nodes on high ports"
  type                     = "ingress"
  from_port                = var.ephemeral_port_start
  to_port                  = var.ephemeral_port_end
  protocol                 = var.sg_tcp_protocol
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.cluster.id
}