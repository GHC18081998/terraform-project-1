# Dynamically fetch the Availability Zone for the Jenkins EBS volume 
# based on the first public subnet provided, eliminating the need for a hardcoded AZ variable.

data "aws_subnet" "jenkins_az_lookup" {
  id       = var.public_subnet_ids[0]
}
