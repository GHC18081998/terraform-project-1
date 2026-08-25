# ==============================================================
# S3 Bucket Server-Side Encryption
# ==============================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  for_each = var.buckets

  # Updated from aws_s3_bucket.this to aws_s3_bucket.buckets
  bucket   = aws_s3_bucket.buckets[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    # This saves you from massive KMS API billing charges!
    bucket_key_enabled = true
  }
}
