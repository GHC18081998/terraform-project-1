# ============================================================
# ECR Lifecycle Policy (Dynamic per repository)
# ============================================================
resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = var.repositories
  repository = aws_ecr_repository.registry[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after ${each.value.untagged_image_expiry_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = each.value.untagged_image_expiry_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last ${each.value.tagged_image_max_count} tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = each.value.tagged_prefixes
          countType     = "imageCountMoreThan"
          countNumber   = each.value.tagged_image_max_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}