# ==============================================================
# S3 Bucket Versioning
# ==============================================================

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = var.buckets

  # Updated from aws_s3_bucket.this to aws_s3_bucket.buckets
  bucket   = aws_s3_bucket.buckets[each.key].id

  versioning_configuration {
    status = each.value.versioning_enabled ? "Enabled" : "Suspended"
  }
}