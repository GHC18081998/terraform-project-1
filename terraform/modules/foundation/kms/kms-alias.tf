# ==============================================================
# KMS Alias Resources
# ==============================================================

resource "aws_kms_alias" "this" {
  name          = "alias/${local.name_prefix}-${var.key_purpose}"
  target_key_id = aws_kms_key.this.key_id
}