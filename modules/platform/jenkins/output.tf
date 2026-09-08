output "jenkins_instance_id" {
  description = "The ID of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.id
}

output "jenkins_private_ip" {
  description = "The private IP address of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.private_ip
}
