output "jenkins_alb_dns" {
  description = "The DNS name of the Jenkins Application Load Balancer"
  value       = aws_lb.jenkins_alb.dns_name
}

output "tools_alb_dns" {
  description = "The DNS name of the Tools (Nexus & SonarQube) Application Load Balancer"
  value       = aws_lb.tools_alb.dns_name
}

output "jenkins_tg_arn" {
  description = "The ARN of the Jenkins Target Group"
  value       = aws_lb_target_group.jenkins_tg.arn
}

output "nexus_tg_arn" {
  description = "The ARN of the Nexus Target Group"
  value       = aws_lb_target_group.nexus_tg.arn
}

output "sonar_tg_arn" {
  description = "The ARN of the SonarQube Target Group"
  value       = aws_lb_target_group.sonar_tg.arn
}

output "jenkins_sg_id" {
  description = "The Security Group ID assigned to the Jenkins EC2 instance"
  value       = aws_security_group.jenkins_ec2_sg.id
}

output "nexus_sg_id" {
  description = "The Security Group ID assigned to the Nexus EC2 instance"
  value       = aws_security_group.nexus_ec2_sg.id
}

output "sonar_sg_id" {
  description = "The Security Group ID assigned to the SonarQube EC2 instance"
  value       = aws_security_group.sonar_ec2_sg.id
}

output "jenkins_ebs_volume_id" {
  description = "The ID of the EBS volume created for Jenkins data persistence"
  value       = aws_ebs_volume.jenkins_data.id
}
