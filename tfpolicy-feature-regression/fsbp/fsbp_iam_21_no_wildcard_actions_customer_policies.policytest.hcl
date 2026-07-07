# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_iam_21_no_wildcard_actions_customer_policies.policy.hcl"]
}

resource "aws_iam_policy" "pass_specific" {
  expect_failure = false
  attrs = {
    name   = "specific"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"s3:GetObject\",\"s3:PutObject\"],\"Resource\":[\"*\"]}]}"
  }
  meta = { provider_type = "aws" }
}

resource "aws_iam_policy" "fail_service_wildcard" {
  expect_failure = true
  attrs = {
    name   = "s3-star"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"s3:*\",\"Resource\":\"*\"}]}"
  }
  meta = { provider_type = "aws" }
}
