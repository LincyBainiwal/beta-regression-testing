# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
#
# Minimal Terraform config for apply-time policy testing.
# Uses only the `random` provider — no real AWS credentials needed.

terraform {
  cloud {
    organization = "nagateja-test-org"
    workspaces {
      name = "beta-regression-testing-lincy"
    }
  }

  required_version = ">= 1.5.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.100.0"
    }
  }
}

provider "aws" {
  region = var.region
  
  # Add default tags for all AWS resources
  default_tags {
    tags = {
      Environment = "staging"
      Compliance  = "required"
      Team        = "platform"
      ManagedBy   = "terraform"
    }
  }
}

provider "random" {}

# Use random_pet for testing workspace tags without AWS credentials
resource "random_pet" "test" {
  length = 2
  prefix = "workspace-tags-test"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Simple S3 bucket — target for apply-time policy evaluation
resource "aws_s3_bucket" "apply_time_test" {
  bucket = "${var.bucket_prefix}apply-time-test-${random_id.suffix.hex}"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "apply_time_test" {
  bucket                  = aws_s3_bucket.apply_time_test.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Add data source for testing core::getdatasources
data "aws_caller_identity" "current" {}

# Add EC2 instance to show cost estimation
# Commented out to avoid AMI/permission issues during testing
# resource "aws_instance" "cost_test" {
#   ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (us-east-1)
#   instance_type = "t3.micro"
#
#   tags = merge(var.tags, {
#     Name = "cost-estimation-test"
#   })
# }
