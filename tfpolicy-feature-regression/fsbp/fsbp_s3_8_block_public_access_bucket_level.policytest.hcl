# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_s3_8_block_public_access_bucket_level.policy.hcl"]
}

resource "aws_s3_bucket_public_access_block" "pass" {
  expect_failure = false
  attrs = {
    bucket                  = "compliant-bucket"
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
  meta = { provider_type = "aws" }
}

resource "aws_s3_bucket_public_access_block" "fail_one_off" {
  expect_failure = true
  attrs = {
    bucket                  = "partial-bucket"
    block_public_acls       = true
    block_public_policy     = false
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
  meta = { provider_type = "aws" }
}

resource "aws_s3_bucket_public_access_block" "fail_missing" {
  expect_failure = true
  attrs = {
    bucket = "missing-flags-bucket"
  }
  meta = { provider_type = "aws" }
}
