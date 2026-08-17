# ==============================================================
# S3 Buckets
# ==============================================================

resource "aws_s3_bucket" "buckets" {
  for_each = var.buckets

  # Guarantees global uniqueness by appending the AWS Account ID
  bucket = "${local.name_prefix}-${each.key}-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-${each.key}" },
    each.value.tags
  )
}
