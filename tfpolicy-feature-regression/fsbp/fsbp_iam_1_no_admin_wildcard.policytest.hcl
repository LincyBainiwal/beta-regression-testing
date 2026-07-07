# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_iam_1_no_admin_wildcard.policy.hcl"]
}

resource "aws_iam_policy" "pass_scoped" {
  expect_failure = false
  attrs = {
    name   = "scoped-read"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"s3:GetObject\"],\"Resource\":[\"arn:aws:s3:::bucket/*\"]}]}"
  }
  meta = { provider_type = "aws" }
}

resource "aws_iam_policy" "fail_admin_wildcard" {
  expect_failure = true
  attrs = {
    name   = "god-mode"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
  }
  meta = { provider_type = "aws" }
}

resource "aws_iam_policy" "fail_admin_wildcard_array" {
  expect_failure = true
  attrs = {
    name   = "god-mode-array"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"*\"],\"Resource\":[\"*\"]}]}"
  }
  meta = { provider_type = "aws" }
}
