# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_ec2_9_no_public_ipv4.policy.hcl"]
}

resource "aws_instance" "pass_private" {
  expect_failure = false
  attrs = {
    tags                        = [{ Name = "private-instance" }]
    associate_public_ip_address = false
  }
  meta = { provider_type = "aws" }
}

resource "aws_instance" "pass_unset" {
  expect_failure = false
  attrs = {
    tags = [{ Name = "unset-instance" }]
  }
  meta = { provider_type = "aws" }
}

resource "aws_instance" "fail_public" {
  expect_failure = true
  attrs = {
    tags                        = [{ Name = "public-instance" }]
    associate_public_ip_address = true
  }
  meta = { provider_type = "aws" }
}
