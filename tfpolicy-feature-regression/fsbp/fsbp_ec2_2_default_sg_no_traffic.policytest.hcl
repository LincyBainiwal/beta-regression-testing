# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_ec2_2_default_sg_no_traffic.policy.hcl"]
}

resource "aws_default_security_group" "pass_empty" {
  expect_failure = false
  attrs = {
    ingress = []
    egress  = []
  }
  meta = { provider_type = "aws" }
}

resource "aws_default_security_group" "fail_has_ingress" {
  expect_failure = true
  attrs = {
    ingress = [{ from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"] }]
    egress  = []
  }
  meta = { provider_type = "aws" }
}

resource "aws_default_security_group" "fail_has_egress" {
  expect_failure = true
  attrs = {
    ingress = []
    egress  = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  }
  meta = { provider_type = "aws" }
}
