# ==============================================================
# S3 Bucket Policy (Enforce HTTPS/TLS)
# ==============================================================

resource "aws_s3_bucket_policy" "bucket_policy" {
  for_each = var.buckets

  bucket = aws_s3_bucket.buckets[each.key].id

  # Reaches into data.tf to grab the policy document
  policy = data.aws_iam_policy_document.bucket_policy[each.key].json

  depends_on = [
    aws_s3_bucket_public_access_block.public_access_block
  ]
}