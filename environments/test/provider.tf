# ==============================================================
# Provider Configurations
# ==============================================================
# Location: environments/test/provider.tf

# ==============================================================
# AWS Provider Configuration
# ==============================================================
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Owner       = var.owner
    }
  }
}

# ==============================================================
# Helm Provider Configuration (Linked to EKS)
# ==============================================================
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

# ==============================================================
# Kubectl Provider Configuration (Linked to EKS)
# ==============================================================
provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

# ==============================================================
# Auto-Install CLI Tools (Helm & Kubectl) - Formatting Safe Version
# ==============================================================
resource "null_resource" "install_cli_tools" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "command -v helm >/dev/null 2>&1 || curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash ; command -v kubectl >/dev/null 2>&1 || (curl -sLO https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.0/2024-09-12/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl)"
  }

  triggers = {
    always_run = timestamp()
  }
}
