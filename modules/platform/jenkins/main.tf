resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type             # Replaced "t3.medium"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  
  iam_instance_profile   = var.iam_instance_profile

  # Passing parameters dynamically to the script
  user_data = templatefile("${path.module}/userdata.sh", {
    java_version = var.java_version
  })
  
  tags = merge(var.tags, { Name = "Jenkins-Server" })
}

resource "aws_volume_attachment" "jenkins_vol_attach" {
  device_name = "/dev/xvdf"
  volume_id   = var.ebs_volume_id
  instance_id = aws_instance.jenkins.id
}

resource "aws_lb_target_group_attachment" "jenkins_tg_attach" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.jenkins.id
  port             = var.jenkins_port                # Replaced 8080
}
