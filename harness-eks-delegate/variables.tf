variable "region" {
  description = "AWS region"
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  default     = "1.29"
}

variable "account_id" {
  description = "Harness account ID"
}

variable "delegate_token" {
  description = "Harness delegate token"
}

variable "delegate_name" {
  description = "Name of the delegate (must follow Helm release naming rules)"
  default     = "harness-delegate"
}

variable "delegate_namespace" {
  description = "Kubernetes namespace where delegate will be deployed"
  default     = "harness-delegate-ng"
}

variable "manager_endpoint" {
  description = "Harness Manager endpoint"
  default     = "https://app.harness.io"
}

variable "delegate_image" {
  description = "Delegate image tag (example: harness/delegate:25.04.85701)"
  default     = "harness/delegate:25.04.85701"
}

variable "replicas" {
  description = "Number of delegate replicas"
  default     = 1
}
