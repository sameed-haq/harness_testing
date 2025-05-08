terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
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

# Install Harness Delegate via Terraform module (Helm under the hood)
module "delegate" {
  source  = "harness/harness-delegate/kubernetes"
  version = "0.1.8"

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

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  value       = module.eks.cluster_certificate_authority_data
}
