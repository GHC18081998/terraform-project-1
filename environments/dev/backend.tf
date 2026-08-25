# ==============================================================
# DEV Environment - S3 Backend Configuration
# Location: terraform/environments/dev/backend.tf
# ==============================================================

terraform {
backend "s3" {
  bucket         = "phase-2-project-74089075418"
  key            = "networking/dev/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "myproject-terraform-state-lock"
  encrypt        = true
  kms_key_id     = "alias/myproject-terraform-state"
  }
}
