# Harness Delegate on EKS using Terraform

This Terraform example provisions an AWS EKS cluster and installs a Harness Kubernetes Delegate via Terraform module.

## Prerequisites

- AWS account with permissions to create VPC, EKS, IAM
- Terraform CLI v1.3.0+
- AWS CLI configured with credentials
- kubectl installed

## Usage

1. Clone this repository:

   ```bash
   git clone <repo-url>
   cd harness-eks-delegate
   ```

2. Create a terraform.tfvars file:

    ```bash
    account_id       = "<HARNESS_ACCOUNT_ID>"
    delegate_token   = "<HARNESS_DELEGATE_TOKEN>"
    region           = "<AWS_REGION>"
    manager_endpoint = "<HARNESS_MANAGER_ENDPOINT>"
    delegate_image   = "<DELEGATE_IMAGE_VER>"
   ```

3. Initialize, Plan and Apply Terraform:

    ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. Verify the delegate is running:

    ```bash
    kubectl get pods -n harness-delegate-ng
   ```
