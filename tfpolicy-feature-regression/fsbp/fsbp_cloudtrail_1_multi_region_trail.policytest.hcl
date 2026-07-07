# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_cloudtrail_1_multi_region_trail.policy.hcl"]
}

resource "aws_cloudtrail" "multi_region" {
  skip = true
  attrs = {
    name                  = "org-trail"
    is_multi_region_trail = true
    enable_logging        = true
  }
  meta = { provider_type = "aws" }
}

provider "aws" "pass" {
  expect_failure = false
  meta = { type = "aws", version = "5.100.0" }
}
