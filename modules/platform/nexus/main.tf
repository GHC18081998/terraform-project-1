resource "aws_instance" "nexus" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type             # Replaced "t3.medium"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  
  iam_instance_profile   = var.iam_instance_profile

  # Passing parameters dynamically to the script
  user_data = templatefile("${path.module}/userdata.sh", {
    app_dir       = var.app_dir
    nexus_version = var.nexus_version
    java_package  = var.java_package
    nexus_user    = var.nexus_user
  })
  
  tags = merge(var.tags, { Name = "Nexus-Server" })
}

resource "aws_lb_target_group_attachment" "nexus_tg_attach" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.nexus.id
  port             = var.nexus_port                      # Replaced 8081
}
