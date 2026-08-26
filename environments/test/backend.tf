terraform {
  backend "s3" {
    bucket         = "myproject-terraform-state-locking-bucket"
    key            = "environments/test/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "alias/myproject-terraform-state"
    dynamodb_table = "myproject-terraform-state-lock"
  }
}
