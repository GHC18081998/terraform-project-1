# ============================================================
# ECR Repositories
# ============================================================
resource "aws_ecr_repository" "registry" {
  # Loops directly through the simplified variable we created
  for_each             = var.repositories

  # Automatically names repos like "prod-frontend" or "test-backend"
  name                 = "${var.environment}-${each.key}"
  image_tag_mutability = each.value.image_tag_mutability

  # Basic Image Scanning
  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  # Uses default AWS encryption (AES256) - no custom KMS required
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    local.common_tags, 
    {
      Name           = "${var.environment}-${each.key}"
      RepositoryType = each.key
    },
    var.extra_tags
  )
}