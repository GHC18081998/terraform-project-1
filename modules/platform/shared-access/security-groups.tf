# ================= US-EAST-1 (Jenkins) =================
resource "aws_security_group" "jenkins_alb_sg" {
  name     = "${var.name_prefix}-jenkins-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.lb_port
    to_port     = var.lb_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.anywhere_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = local.all_protocols
    cidr_blocks = local.anywhere_cidr
  }
  tags = merge(var.tags, { Name = "${var.name_prefix}-jenkins-alb-sg" })
}

resource "aws_security_group" "jenkins_ec2_sg" {
  name     = "${var.name_prefix}-jenkins-ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.jenkins_port
    to_port         = var.jenkins_port
    protocol        = local.tcp_protocol
    security_groups = [aws_security_group.jenkins_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = local.all_protocols
    cidr_blocks = local.anywhere_cidr
  }
  tags = merge(var.tags, { Name = "jenkins-ec2-sg" })
}

# ================= US-EAST-2 (Nexus & Sonar) =================
resource "aws_security_group" "tools_alb_sg" {
  name     = "${var.name_prefix}-tools-alb-sg"
  vpc_id   = var.vpc_id

  ingress {
    from_port   = var.lb_port
    to_port     = var.lb_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.anywhere_cidr
  }

  ingress {
    from_port   = var.sonar_port
    to_port     = var.sonar_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.anywhere_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = local.all_protocols
    cidr_blocks = local.anywhere_cidr
  }
  tags = merge(var.tags, { Name = "tools-alb-sg" })
}

resource "aws_security_group" "nexus_ec2_sg" {
  name     = "${var.name_prefix}-nexus-ec2-sg"
  vpc_id   = var.vpc_id

  ingress {
    from_port       = var.nexus_port
    to_port         = var.nexus_port
    protocol        = local.tcp_protocol
    security_groups = [aws_security_group.tools_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = local.all_protocols
    cidr_blocks = local.anywhere_cidr
  }
  tags = merge(var.tags, { Name = "nexus-ec2-sg" })
}

resource "aws_security_group" "sonar_ec2_sg" {
  name     = "${var.name_prefix}-sonar-ec2-sg"
  vpc_id   = var.vpc_id

  ingress {
    from_port       = var.sonar_port
    to_port         = var.sonar_port
    protocol        = local.tcp_protocol
    security_groups = [aws_security_group.tools_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = local.all_protocols
    cidr_blocks = local.anywhere_cidr
  }
  tags = merge(var.tags, { Name = "sonar-ec2-sg" })
}
