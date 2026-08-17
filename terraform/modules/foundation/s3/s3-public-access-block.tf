# ==============================================================
# S3 Public Access Block (Security Baseline)
# ==============================================================

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  for_each                = var.buckets

  # Updated from aws_s3_bucket.this to aws_s3_bucket.buckets
  bucket                  = aws_s3_bucket.buckets[each.key].id

  # Hardcoded to true to enforce strict security baselines
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}