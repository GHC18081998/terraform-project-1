# ============================================================
# Karpenter Controller IAM Role & Policy
# ============================================================
resource "aws_iam_role" "controller" {
  count              = var.enable_karpenter ? 1 : 0
  name_prefix        = "${var.environment}-karpenter-controller-"
  assume_role_policy = data.aws_iam_policy_document.controller_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "controller" {
  count  = var.enable_karpenter ? 1 : 0
  name   = "${var.environment}-karpenter-controller-policy"
  role   = aws_iam_role.controller[0].id
  policy = data.aws_iam_policy_document.controller_policy.json
}

# ============================================================
# Karpenter Node IAM Role
# ============================================================
resource "aws_iam_role" "node" {
  count       = var.enable_karpenter ? 1 : 0
  name_prefix = "${var.environment}-karpenter-node-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = local.common_tags
}

# ============================================================
# Standard EKS Node Policies
# ============================================================
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  count      = var.enable_karpenter ? 1 : 0
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  count      = var.enable_karpenter ? 1 : 0
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  count      = var.enable_karpenter ? 1 : 0
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_AmazonSSMManagedInstanceCore" {
  count      = var.enable_karpenter ? 1 : 0
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node[0].name
}

# ============================================================
# REQUIRED: Cluster Access Entry for Karpenter Nodes
# ============================================================
resource "aws_eks_access_entry" "karpenter_node" {
  count      = var.enable_karpenter ? 1 : 0
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.node[0].arn
  type          = "EC2_LINUX"
}
