resource "aws_lb_target_group" "jenkins_tg" {
  name     = "${var.name_prefix}-jenkins-tg"
  port     = var.jenkins_port
  protocol = local.http_protocol
  vpc_id   = var.vpc_id

  health_check {
    path = var.jenkins_hc_path
  }
  tags = merge(var.tags, { Name = "${var.name_prefix}-jenkins-tg" })
}

resource "aws_lb_target_group" "nexus_tg" {
  name     = "${var.name_prefix}-nexus-tg"
  port     = var.nexus_port
  protocol = local.http_protocol
  vpc_id   = var.vpc_id

  health_check {
    path = var.nexus_hc_path
  }
  tags = merge(var.tags, { Name = "${var.name_prefix}-nexus-tg" })
}

resource "aws_lb_target_group" "sonar_tg" {
  name     = "${var.name_prefix}-sonar-tg"
  port     = var.sonar_port
  protocol = local.http_protocol
  vpc_id   = var.vpc_id

  health_check {
    path    = var.sonar_hc_path
    matcher = var.sonar_hc_matcher
  }
  tags = merge(var.tags, { Name = "${var.name_prefix}-sonar-tg" })
}
