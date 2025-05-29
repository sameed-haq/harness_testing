terraform {
  required_version = ">= 1.4.0"
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = var.bucket_name

  tags = {
    "Environment" = "Test"
    "ManagedBy"   = "HarnessIACM"
  }

  lifecycle {
    prevent_destroy = true
  }
}
