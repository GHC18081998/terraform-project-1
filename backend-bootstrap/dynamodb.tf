# ==============================================================
# DynamoDB Table for Terraform State Locking
# ==============================================================

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = local.table_name
  billing_mode = var.billing_mode
  hash_key     = "LockID"

  # Required attribute for Terraform state locking
  attribute {
    name = "LockID"
    type = "S"
  }

  # KMS Encryption
  server_side_encryption {
    enabled     = true
    kms_key_arn = local.kms_key_arn
  }

  # Point-in-Time Recovery
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = merge(local.common_tags, {
    Name    = local.table_name
    Purpose = "TerraformStateLocking"
  })

  lifecycle {
    prevent_destroy = false
  }
}
