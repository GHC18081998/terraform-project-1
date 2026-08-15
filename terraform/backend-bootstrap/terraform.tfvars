# ==============================================================
# Global Configuration
# ==============================================================
aws_region   = "us-east-1"
project_name = "myproject"
environment  = "bootstrap"
owner        = "aws-devops-team"

# ==============================================================
# S3 Configuration (State Storage)
# ==============================================================
bucket_name                        = "myproject-terraform-state-274089075418"
enable_versioning                  = true
enable_lifecycle_rules             = true
noncurrent_version_expiration_days = 90
force_destroy                      = false

# ==============================================================
# DynamoDB Configuration (State Locking)
# ==============================================================
table_name                    = "myproject-terraform-state-lock"
billing_mode                  = "PAY_PER_REQUEST"
enable_point_in_time_recovery = true

# ==============================================================
# KMS Configuration (State Encryption)
# ==============================================================
kms_deletion_window_in_days = 30
kms_enable_key_rotation     = true
kms_alias_name              = "myproject-terraform-state"
kms_description             = "KMS key for encrypting Terraform remote state files"

# Note: If this Terraform code is actively creating the KMS key, you usually do not
# hardcode the ARN here, as Terraform doesn't know it yet. However, if the key
# already exists in your account and you are just referencing it, this is correct.
kms_key_arn = "arn:aws:kms:us-east-1:274089075418:key/23518b88-b9c5-4c9a-82bb-d10160e8326b"
