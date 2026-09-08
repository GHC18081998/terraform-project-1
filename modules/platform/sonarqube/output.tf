output "sonarqube_instance_id" {
  description = "The ID of the SonarQube EC2 instance"
  value       = aws_instance.sonarqube.id
}

output "sonarqube_private_ip" {
  description = "The private IP address of the SonarQube EC2 instance"
  value       = aws_instance.sonarqube.private_ip
}

output "postgres_volume_id" {
  description = "The ID of the dedicated PostgreSQL EBS volume"
  value       = aws_ebs_volume.postgres_data.id
}

output "sonarqube_data_volume_id" {
  description = "The ID of the dedicated EBS volume for SonarQube bug and project history data"
  value       = aws_ebs_volume.sonarqube_data.id
}
