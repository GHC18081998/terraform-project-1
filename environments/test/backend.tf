terraform {
backend "s3" {
bucket="phase-2-project-74089075418"
key="environments/test/terraform.tfstate"
region="us-east-1"
dynamodb_table="myproject-terraform-state-lock"
encrypt=true
kms_key_id="alias/myproject-terraform-state"
}
}
