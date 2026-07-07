# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_ec2_13_no_ssh_from_anywhere.policy.hcl"]
}

resource "aws_security_group" "pass_scoped_ssh" {
  expect_failure = false
  attrs = {
    ingress = [
      { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"] },
    ]
  }
  meta = { provider_type = "aws" }
}

resource "aws_security_group" "fail_open_ssh" {
  expect_failure = true
  attrs = {
    ingress = [
      { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    ]
  }
  meta = { provider_type = "aws" }
}

resource "aws_security_group" "fail_open_rdp" {
  expect_failure = true
  attrs = {
    ingress = [
      { from_port = 3389, to_port = 3389, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    ]
  }
  meta = { provider_type = "aws" }
}

resource "aws_security_group" "fail_wide_range" {
  expect_failure = true
  attrs = {
    ingress = [
      { from_port = 0, to_port = 65535, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    ]
  }
  meta = { provider_type = "aws" }
}
