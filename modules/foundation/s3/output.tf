# ==============================================================
# S3 Bucket Outputs
# ==============================================================

output "bucket_ids" {
  description = "Map of bucket keys to their generated S3 bucket IDs (names)"
  value       = { for k, v in aws_s3_bucket.buckets : k => v.id }
}

output "bucket_arns" {
  description = "Map of bucket keys to their corresponding S3 bucket ARNs"
  value       = { for k, v in aws_s3_bucket.buckets : k => v.arn }
}
