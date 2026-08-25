# ==============================================================================
# IAM Role & Policy for AWS Load Balancer Controller (IRSA)
# ==============================================================================

# 1. Create the IAM Policy from the native Terraform policy document (policy.tf)
resource "aws_iam_policy" "lb_controller" {
  count       = var.enable_aws_load_balancer_controller ? 1 : 0

  name        = local.iam_policy_name
  description = "${var.lb_controller_iam_policy_description} - ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.lb_controller[0].json

  tags        = local.common_tags
}

# 2. Create the IAM Role (Uses the assume role document from data.tf)
resource "aws_iam_role" "lb_controller" {
  count              = var.enable_aws_load_balancer_controller ? 1 : 0

  name               = local.iam_role_name
  description        = "${var.lb_controller_iam_role_description} - ${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.lb_controller_assume_role[0].json

  tags               = local.common_tags
}

# 3. Attach the Policy to the Role
resource "aws_iam_role_policy_attachment" "lb_controller" {
  count      = var.enable_aws_load_balancer_controller ? 1 : 0

  role       = aws_iam_role.lb_controller[0].name
  policy_arn = aws_iam_policy.lb_controller[0].arn
}
