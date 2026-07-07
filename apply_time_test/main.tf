# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
#
# Minimal Terraform config for apply-time policy testing.
# Uses only the `random` provider — no real AWS credentials needed.

terraform {
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
}

provider "random" {}

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

resource "random_id" "suffix" {
  byte_length = 4
}
