# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_rds_3_encryption_at_rest.policy.hcl"]
}

resource "aws_kms_key" "data_key" {
  skip = true
  attrs = {
    key_id = "1234abcd-12ab-34cd-56ef-1234567890ab"
    arn    = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
  }
  meta = { provider_type = "aws" }
}

resource "aws_db_instance" "pass_default_encryption" {
  expect_failure = false
  attrs = {
    identifier        = "encrypted-default"
    storage_encrypted = true
  }
  meta = { provider_type = "aws" }
}

resource "aws_db_instance" "pass_cmk" {
  expect_failure = false
  attrs = {
    identifier        = "encrypted-cmk"
    storage_encrypted = true
    kms_key_id        = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
  }
  meta = { provider_type = "aws" }
}

resource "aws_db_instance" "fail_unencrypted" {
  expect_failure = true
  attrs = {
    identifier        = "unencrypted"
    storage_encrypted = false
  }
  meta = { provider_type = "aws" }
}

resource "aws_db_instance" "fail_unknown_kms" {
  expect_failure = true
  attrs = {
    identifier        = "unknown-kms"
    storage_encrypted = true
    kms_key_id        = "arn:aws:kms:us-east-1:111122223333:key/dead-beef"
  }
  meta = { provider_type = "aws" }
}
