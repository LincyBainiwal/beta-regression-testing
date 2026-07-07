# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_s3_14_versioning_enabled.policy.hcl"]
}

resource "aws_s3_bucket_versioning" "enabled_versioning" {
  skip = true
  attrs = {
    bucket = "versioned-bucket"
    versioning_configuration = [{
      status = "Enabled"
    }]
  }
  meta = { provider_type = "aws" }
}

resource "aws_s3_bucket_versioning" "suspended_versioning" {
  skip = true
  attrs = {
    bucket = "suspended-bucket"
    versioning_configuration = [{
      status = "Suspended"
    }]
  }
  meta = { provider_type = "aws" }
}

resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "versioned-bucket" }
  meta  = { provider_type = "aws" }
}

resource "aws_s3_bucket" "fail_suspended" {
  expect_failure = true
  attrs = { bucket = "suspended-bucket" }
  meta  = { provider_type = "aws" }
}

resource "aws_s3_bucket" "fail_no_versioning_resource" {
  expect_failure = true
  attrs = { bucket = "no-versioning-bucket" }
  meta  = { provider_type = "aws" }
}
