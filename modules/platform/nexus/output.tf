output "nexus_instance_id" {
  description = "The ID of the Nexus EC2 instance"
  value       = aws_instance.nexus.id
}

output "nexus_private_ip" {
  description = "The private IP address of the Nexus EC2 instance"
  value       = aws_instance.nexus.private_ip
}
