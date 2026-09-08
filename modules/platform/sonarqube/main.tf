resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile   = var.iam_instance_profile

  # ---------------------------------------------------------
  # 30GB EBS Volume Configuration
  # ---------------------------------------------------------
  root_block_device {
    volume_size           = var.ebs_volume_size
    volume_type           = var.ebs_volume_type
    encrypted             = true
    delete_on_termination = false # Prevents accidental data loss
  }

  # =========================================================
  # SECURE USER DATA INJECTION
  # =========================================================
  user_data = templatefile("${path.module}/userdata.sh", {
    # 1. Secret Manager Info (Replaces raw credentials)
    secret_id            = var.secret_id
    aws_region           = var.aws_region

    # 2. Docker & App Config
    sonar_container_name = var.sonar_container_name
    sonar_host_port      = var.sonar_host_port
    sonar_container_port = var.sonar_container_port
    sonar_image          = var.sonar_image
    postgres_version     = var.postgres_version

    # 3. Base OS Config 
    # (Only keep these if you reverted to the manual native installation script)
    docker_repo_url      = var.docker_repo_url
    docker_package       = var.docker_package
    java_version         = var.java_version
    db_port              = var.db_port

    # 4. Dynamically inject the backup bucket name
    s3_backup_bucket     = var.s3_backup_bucket
  })

  tags = merge(var.tags, { Name = "SonarQube-Server" })
}

resource "aws_lb_target_group_attachment" "sonar_attach" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.sonarqube.id
  
  # Ensure this port matches what your container actually exposes to the EC2 host
  port             = var.sonar_host_port 
}

# ==============================================================
# SonarQube-Specific Database Credentials (Self-Contained & Dynamic)
# ==============================================================
resource "random_password" "sonar_db_password" {
  length           = var.sonar_password_length
  special          = var.sonar_password_special
  override_special = var.sonar_password_override_special
}

resource "aws_secretsmanager_secret" "db_secret" {
  name                    = "${var.project_name}-${var.environment}-sonarqube-db-credentials"
  description             = "SonarQube PostgreSQL credentials"
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username # Dynamically driven via variable, no hardcoding
    password = random_password.sonar_db_password.result
  })
}


# =========================================================
# Dedicated EBS Volume for SonarQube Bug / Project Data
# =========================================================
resource "aws_ebs_volume" "sonarqube_data" {
  availability_zone = aws_instance.sonarqube.availability_zone
  size              = var.sonarqube_data_volume_size
  type              = var.sonarqube_data_volume_type
  encrypted         = var.sonarqube_data_volume_encrypted

  tags = merge(var.tags, { Name = "SonarQube-Bugs-Data" })
}

resource "aws_volume_attachment" "sonarqube_data_att" {
  device_name = var.sonarqube_data_device_name
  volume_id   = aws_ebs_volume.sonarqube_data.id
  instance_id = aws_instance.sonarqube.id

  lifecycle {
    prevent_destroy = false # Must be a static boolean, not a variable
  }
}



# =========================================================
# Dedicated EBS Volume for PostgreSQL
# =========================================================
resource "aws_ebs_volume" "postgres_data" {
  availability_zone = aws_instance.sonarqube.availability_zone
  size              = var.postgres_volume_size
  type              = var.postgres_volume_type
  encrypted         = var.postgres_volume_encrypted

  tags = merge(var.tags, { Name = "SonarQube-Postgres-Data" })
}

resource "aws_volume_attachment" "postgres_data_att" {
  device_name = var.postgres_device_name
  volume_id   = aws_ebs_volume.postgres_data.id
  instance_id = aws_instance.sonarqube.id
  
  lifecycle {
    prevent_destroy = false # Must be a static boolean, not a variable 
  }
}
