# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["fsbp_rds_13_minor_version_upgrades.policy.hcl"]
}

resource "aws_db_instance" "pass_auto_upgrade" {
  expect_failure = false
  attrs = {
    identifier                  = "auto-upgrade"
    engine                      = "postgres"
    engine_version              = "14.2.0"
    auto_minor_version_upgrade  = true
  }
  meta = { provider_type = "aws" }
}

resource "aws_db_instance" "pass_at_floor" {
  expect_failure = false
  attrs = {
    identifier                  = "at-floor"
    engine                      = "postgres"
    engine_version              = "15.4.0"
    auto_minor_version_upgrade  = false
  }
  meta = { provider_type = "aws" }
}

resource "aws_db_instance" "fail_old_no_auto" {
  expect_failure = true
  attrs = {
    identifier                  = "stale"
    engine                      = "postgres"
    engine_version              = "13.5.0"
    auto_minor_version_upgrade  = false
  }
  meta = { provider_type = "aws" }
}
