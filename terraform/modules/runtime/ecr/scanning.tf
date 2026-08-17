# ============================================================
# ECR Registry Scanning Configuration
# Applies enhanced or continuous scanning at the registry level
# ============================================================
resource "aws_ecr_registry_scanning_configuration" "global_scanning" {
  count     = var.enable_registry_scanning ? 1 : 0
  scan_type = var.registry_scan_type

  rule {
    scan_frequency = var.registry_scan_frequency
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}