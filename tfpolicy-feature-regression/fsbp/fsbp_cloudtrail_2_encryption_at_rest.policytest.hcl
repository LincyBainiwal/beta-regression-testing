# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_cloudtrail_2_encryption_at_rest.policy.hcl"]
}

resource "aws_kms_key" "trail_key" {
  skip = true
  attrs = {
    key_id = "trail-key-id"
    arn    = "arn:aws:kms:us-east-1:111122223333:key/trail-key-id"
  }
  meta = { provider_type = "aws" }
}

resource "aws_cloudtrail" "pass" {
  expect_failure = false
  attrs = {
    name       = "encrypted-trail"
    kms_key_id = "arn:aws:kms:us-east-1:111122223333:key/trail-key-id"
  }
  meta = { provider_type = "aws" }
}

resource "aws_cloudtrail" "fail_no_kms" {
  expect_failure = true
  attrs = {
    name = "plain-trail"
  }
  meta = { provider_type = "aws" }
}

resource "aws_cloudtrail" "fail_unknown_kms" {
  expect_failure = true
  attrs = {
    name       = "dangling-kms-trail"
    kms_key_id = "arn:aws:kms:us-east-1:111122223333:key/missing"
  }
  meta = { provider_type = "aws" }
}
