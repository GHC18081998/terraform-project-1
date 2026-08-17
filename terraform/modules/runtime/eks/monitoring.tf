resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_days

  # FORCE Terraform to use the local key, ignoring any tfvars that might be hijacking it
  kms_key_id        = aws_kms_key.eks.arn

  tags              = local.common_tags

  # Ensure the KMS Key and its policy are 100% created before CloudWatch tries to use them
  depends_on = [
    aws_kms_key.eks
  ]
}