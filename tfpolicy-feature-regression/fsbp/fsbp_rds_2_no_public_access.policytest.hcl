# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_rds_2_no_public_access.policy.hcl"]
}

resource "aws_db_instance" "pass" {
  expect_failure = false
  attrs = {
    identifier          = "private-db"
    publicly_accessible = false
    storage_encrypted   = true
  }
  meta = { provider_type = "aws" }
}

resource "aws_db_instance" "fail_public" {
  expect_failure = true
  attrs = {
    identifier          = "public-db"
    publicly_accessible = true
    storage_encrypted   = true
  }
  meta = { provider_type = "aws" }
}

resource "aws_db_instance" "fail_unencrypted" {
  expect_failure = true
  attrs = {
    identifier          = "plain-db"
    publicly_accessible = false
    storage_encrypted   = false
  }
  meta = { provider_type = "aws" }
}
