# ==============================================================
# S3 Lifecycle Rules (Storage Cost Optimization)
# ==============================================================

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  # Advanced looping: Only creates this resource if lifecycle_enabled is true
  for_each = { for k, v in var.buckets : k => v if v.lifecycle_enabled }

  # Updated from aws_s3_bucket.this to aws_s3_bucket.buckets
  bucket   = aws_s3_bucket.buckets[each.key].id

  rule {
    id     = "transition-and-expire"
    status = "Enabled"

    filter {}

    # Move infrequently-accessed objects down the storage tiers automatically
    dynamic "transition" {
      for_each = each.value.transitions
      content {
        days          = transition.value.days
        storage_class = transition.value.storage_class
      }
    }

    # Delete current object versions after X days
    dynamic "expiration" {
      for_each = each.value.expiration_days == null ? [] : [each.value.expiration_days]
      content {
        days = expiration.value
      }
    }

    # Delete old, hidden object versions after X days (Vital if versioning is on!)
    dynamic "noncurrent_version_expiration" {
      for_each = each.value.noncurrent_version_expiration_days == null ? [] : [each.value.noncurrent_version_expiration_days]
      content {
        noncurrent_days = noncurrent_version_expiration.value
      }
    }
  }
}

# ==============================================================
# S3 Intelligent-Tiering
# ==============================================================

resource "aws_s3_bucket_intelligent_tiering_configuration" "intelligent_tiering" {
  # Only creates this resource if intelligent_tiering_enabled is true
  for_each = { for k, v in var.buckets : k => v if v.intelligent_tiering_enabled }

  # Updated from aws_s3_bucket.this to aws_s3_bucket.buckets
  bucket   = aws_s3_bucket.buckets[each.key].id

  name     = "EntireBucket"
  status   = "Enabled"

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 90
  }

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
}
