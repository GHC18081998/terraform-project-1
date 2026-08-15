# ==============================================================
# S3 Bucket Outputs (State Storage & Logging)
# ==============================================================

output "s3_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "s3_bucket_region" {
  description = "The region of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.region
}

output "s3_log_bucket_name" {
  description = "The name of the S3 access log bucket"
  value       = aws_s3_bucket.terraform_state_logs.bucket
}

output "s3_log_bucket_arn" {
  description = "The ARN of the S3 access log bucket"
  value       = aws_s3_bucket.terraform_state_logs.arn
}

# ==============================================================
# DynamoDB Outputs (State Locking)
# ==============================================================

output "dynamodb_table_id" {
  description = "The ID of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_state_lock.id
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_state_lock.arn
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "dynamodb_table_hash_key" {
  description = "The hash key of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_state_lock.hash_key
}

output "dynamodb_table_billing_mode" {
  description = "The billing mode of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_state_lock.billing_mode
}

# ==============================================================
# KMS Outputs (State Encryption)
# ==============================================================

output "kms_key_id" {
  description = "The ID of the KMS key"
  value       = aws_kms_key.terraform_state.key_id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.terraform_state.arn
}

output "kms_alias_name" {
  description = "The alias name of the KMS key"
  value       = aws_kms_alias.terraform_state.name
}

output "kms_alias_arn" {
  description = "The ARN of the KMS alias"
  value       = aws_kms_alias.terraform_state.arn
}