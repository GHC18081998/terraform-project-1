resource "aws_ebs_volume" "jenkins_data" {
  availability_zone = data.aws_subnet.jenkins_az_lookup.availability_zone
  size              = var.jenkins_ebs_size
  type              = var.jenkins_ebs_type
  encrypted         = var.is_ebs_encrypted
  tags              = merge(var.tags, { Name = "${var.name_prefix}-jenkins-data-vol" })
}
