data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"] # Amazon Official

  filter {
    name   = "name"
    # Grabs the latest Amazon Linux 2023 AMI
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
