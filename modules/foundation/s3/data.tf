# ==============================================================
# Global Data Sources
# ==============================================================

# Fetches the AWS Account ID for globally unique bucket naming
data "aws_caller_identity" "current" {}

# ==============================================================
# S3 Bucket Policy Documents
# ==============================================================

# Builds the JSON policy to enforce HTTPS/TLS transit encryption
data "aws_iam_policy_document" "bucket_policy" {
  for_each = var.buckets

  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["s3:*"]

    resources = [
      aws_s3_bucket.buckets[each.key].arn,
      "${aws_s3_bucket.buckets[each.key].arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}