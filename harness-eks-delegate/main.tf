terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name = "harness-eks-${random_string.suffix.result}"
}

# Provision VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "harness-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# Provision EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.1"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = ["t3.medium"]
    }
  }
}

resource "null_resource" "wait_for_nodes" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for EKS nodes to become Ready..."
      for i in {1..30}; do
        READY=$(kubectl get nodes --no-headers | grep -c ' Ready')
        if [ "$READY" -ge 1 ]; then
          echo "EKS nodes are Ready."
          exit 0
        fi
        echo "Waiting... attempt $i"
        sleep 20
      done
      echo "Nodes did not become ready in time."
      exit 1
    EOT
  }
}


# Install Harness Delegate via Terraform module (Helm under the hood)
module "delegate" {
  source  = "harness/harness-delegate/kubernetes"
  version = "0.1.8"

  depends_on = [null_resource.wait_for_nodes]

  account_id       = var.account_id
  delegate_token   = var.delegate_token
  delegate_name    = var.delegate_name
  deploy_mode      = "Kubernetes"
  namespace        = var.delegate_namespace
  manager_endpoint = var.manager_endpoint
  delegate_image   = var.delegate_image
  replicas         = var.replicas
  upgrader_enabled = true

  values = yamlencode({
    javaOpts = "-Xms64M"
  })
}