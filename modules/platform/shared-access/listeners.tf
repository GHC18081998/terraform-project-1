resource "aws_lb_listener" "jenkins_listener" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = var.lb_port
  protocol          = local.http_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }
}

resource "aws_lb_listener" "nexus_listener" {
  load_balancer_arn = aws_lb.tools_alb.arn
  port              = var.lb_port
  protocol          = local.http_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexus_tg.arn
  }
}

resource "aws_lb_listener" "sonar_listener" {
  load_balancer_arn = aws_lb.tools_alb.arn
  port              = var.sonar_port
  protocol          = local.http_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sonar_tg.arn
  }
}
