# ============================================================
# IAM Policy — CI/CD Pipeline ECR Push Access
# Attach this to your Jenkins/GitHub Actions/GitLab IAM Role
# ============================================================
resource "aws_iam_policy" "cicd_ecr_access" {
  name        = "${var.environment}-cicd-ecr-push"
  description = "Allows CI/CD pipelines to authenticate and push images to ECR in ${var.environment}"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowECRAuthentication"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = ["*"]
      },
      {
        Sid    = "AllowImagePush"
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages",
          "ecr:ListImages"
        ]
        # Dynamically grabs the ARNs of all repos created in this module
        Resource = [for repo in aws_ecr_repository.registry : repo.arn]
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name   = "${var.environment}-cicd-ecr-push"
    UsedBy = "cicd-pipeline"
  })
}

# ============================================================
# IAM Policy — EKS Node ECR Pull Access
# Attach this to your EKS Node IAM Role / Karpenter Role
# ============================================================
resource "aws_iam_policy" "eks_node_ecr_pull" {
  name        = "${var.environment}-eks-ecr-pull"
  description = "Allows EKS worker nodes to authenticate and pull images from ECR in ${var.environment}"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowECRAuthentication"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = ["*"]
      },
      {
        Sid    = "AllowImagePull"
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
        # Dynamically grabs the ARNs of all repos created in this module
        Resource = [for repo in aws_ecr_repository.registry : repo.arn]
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name   = "${var.environment}-eks-ecr-pull"
    UsedBy = "eks-worker-nodes"
  })
}