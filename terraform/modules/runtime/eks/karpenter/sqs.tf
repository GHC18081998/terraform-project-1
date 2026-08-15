# ==============================================================================
# Karpenter Interruption SQS Queue (Minimal)
# ==============================================================================
resource "aws_sqs_queue" "interruption" {
  count = var.enable_spot_termination_handling ? 1 : 0

  name                      = "${local.name_prefix}-${var.sqs_queue_name_suffix}"
  message_retention_seconds = var.sqs_message_retention_seconds
  sqs_managed_sse_enabled   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-${var.sqs_queue_name_suffix}"
    }
  )
}