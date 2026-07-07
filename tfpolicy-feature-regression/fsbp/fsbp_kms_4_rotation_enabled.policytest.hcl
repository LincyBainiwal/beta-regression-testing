# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_kms_4_rotation_enabled.policy.hcl"]
}

resource "aws_kms_key" "pass_rotating" {
  expect_failure = false
  attrs = {
    customer_master_key_spec = "SYMMETRIC_DEFAULT"
    enable_key_rotation      = true
  }
  meta = { provider_type = "aws" }
}

resource "aws_kms_key" "pass_asymmetric_exempt" {
  expect_failure = false
  attrs = {
    customer_master_key_spec = "RSA_4096"
    enable_key_rotation      = false
  }
  meta = { provider_type = "aws" }
}

resource "aws_kms_key" "fail_no_rotation" {
  expect_failure = true
  attrs = {
    customer_master_key_spec = "SYMMETRIC_DEFAULT"
    enable_key_rotation      = false
  }
  meta = { provider_type = "aws" }
}
