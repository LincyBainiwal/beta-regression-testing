# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP IAM.1 — IAM policies should not allow full "*" administrative privileges
# (no Statement may have Effect=Allow with Action="*" AND Resource="*")
# -----------------------------------------------------------------------------
# Combines: core::jsondecode + nested for-expressions + core::contains
# =============================================================================

policy {
}

resource_policy "aws_iam_policy" "fsbp_iam_1_no_admin_wildcard" {
  locals {
    parsed     = core::jsondecode(core::try(attrs.policy, "{}"))
    statements = core::try(local.parsed.Statement, [])

    admin_statements = [
      for s in local.statements : s
      if core::try(s.Effect, "") == "Allow" &&
         core::contains(core::flatten([core::try(s.Action, [])]), "*") &&
         core::contains(core::flatten([core::try(s.Resource, [])]), "*")
    ]
  }

  enforce {
    condition     = core::length(local.admin_statements) == 0
    error_message = "IAM.1: policy must not grant Action=\"*\" + Resource=\"*\" with Effect=Allow"
  }
}
