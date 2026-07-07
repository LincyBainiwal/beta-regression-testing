# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_s3_1_block_public_access.policy.hcl"]
}

# Sibling BPA resource for the pass case
resource "aws_s3_bucket_public_access_block" "pass_bpa" {
  skip = true
  attrs = {
    bucket                  = "compliant-bucket"
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
  meta = { provider_type = "aws" }
}

resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "compliant-bucket" }
  meta  = { provider_type = "aws" }
}

resource "aws_s3_bucket" "fail_no_bpa" {
  expect_failure = true
  attrs = { bucket = "no-bpa-bucket" }
  meta  = { provider_type = "aws" }
}

# Sibling BPA with one flag false
resource "aws_s3_bucket_public_access_block" "partial_bpa" {
  skip = true
  attrs = {
    bucket                  = "partial-bpa-bucket"
    block_public_acls       = true
    block_public_policy     = false
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
  meta = { provider_type = "aws" }
}

resource "aws_s3_bucket" "fail_partial_bpa" {
  expect_failure = true
  attrs = { bucket = "partial-bpa-bucket" }
  meta  = { provider_type = "aws" }
}
