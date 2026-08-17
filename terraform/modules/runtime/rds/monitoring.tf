# ==============================================================================
# IAM Role for Enhanced Monitoring
# ==============================================================================

resource "aws_iam_role" "rds_monitoring" {
  count = var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0

  name        = local.monitoring_role_name
  description = "IAM role for RDS Enhanced Monitoring - ${local.db_identifier}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RDSMonitoringTrust"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name    = local.monitoring_role_name
    Purpose = "RDS Enhanced Monitoring"
  })
}

# ==============================================================================
# Attach Managed Policy to Monitoring Role
# ==============================================================================

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}