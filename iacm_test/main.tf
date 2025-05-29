terraform {
  required_version = ">= 1.4.0"
}
terraform {
  backend "http" {
    address        = "https://app.harness.io/gateway/iacm/api/orgs/default/projects/Sameed_Test/workspaces/Test_AWS/terraform-backend?accountIdentifier=jGS2jB1ZSZG2RiLHVR0gew"
    username       = "harness"
    lock_address   = "https://app.harness.io/gateway/iacm/api/orgs/default/projects/Sameed_Test/workspaces/Test_AWS/terraform-backend/lock?accountIdentifier=jGS2jB1ZSZG2RiLHVR0gew"
    lock_method    = "POST"
    unlock_address = "https://app.harness.io/gateway/iacm/api/orgs/default/projects/Sameed_Test/workspaces/Test_AWS/terraform-backend/lock?accountIdentifier=jGS2jB1ZSZG2RiLHVR0gew"
    unlock_method  = "DELETE"
  }
}
provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = var.bucket_name

  tags = {
    "Environment" = "Test"
    "ManagedBy"   = "HarnessIACM"
    "Owner"       = "Sameed"
  }

  lifecycle {
    prevent_destroy = false
  }
}
