# ==============================================================
# KMS Key for Terraform State Encryption
# ==============================================================

resource "aws_kms_key" "terraform_state" {
  description             = var.kms_description
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-terraform-state-kms"
  })
}

# ==============================================================
# KMS Key Alias
# ==============================================================

resource "aws_kms_alias" "terraform_state" {
  name          = local.kms_alias
  target_key_id = aws_kms_key.terraform_state.key_id
}
