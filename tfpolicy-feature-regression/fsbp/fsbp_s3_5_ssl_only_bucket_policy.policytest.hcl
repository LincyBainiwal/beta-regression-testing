# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_s3_5_ssl_only_bucket_policy.policy.hcl"]
}

resource "aws_s3_bucket_policy" "pass" {
  expect_failure = false
  attrs = {
    bucket = "compliant-bucket"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::compliant-bucket/*\",\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
  }
  meta = { provider_type = "aws" }
}

resource "aws_s3_bucket_policy" "fail_no_ssl_clause" {
  expect_failure = true
  attrs = {
    bucket = "noncompliant-bucket"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::noncompliant-bucket/*\"}]}"
  }
  meta = { provider_type = "aws" }
}
