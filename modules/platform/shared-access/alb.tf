resource "aws_lb" "jenkins_alb" {
  name               = "${var.name_prefix}-jenkins-alb"
  internal           = var.is_internal_alb
  load_balancer_type = local.alb_type
  security_groups    = [aws_security_group.jenkins_alb_sg.id]
  subnets            = var.public_subnet_ids
  tags               = merge(var.tags, { Name = "${var.name_prefix}-jenkins-alb" })
}

resource "aws_lb" "tools_alb" {
  name               = "${var.name_prefix}-tools-alb"
  internal           = var.is_internal_alb
  load_balancer_type = local.alb_type
  security_groups    = [aws_security_group.tools_alb_sg.id]
  subnets            = var.public_subnet_ids
  tags               = merge(var.tags, { Name = "${var.name_prefix}-tools-alb" })
}
