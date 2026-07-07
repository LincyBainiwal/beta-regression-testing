# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP IAM.21 — IAM customer managed policies should not allow wildcard actions
# (no Statement Action may be "service:*"; specific actions only)
# -----------------------------------------------------------------------------
# Combines: core::jsondecode + nested for-expressions + core::endswith + locals
# =============================================================================

policy {
}

resource_policy "aws_iam_policy" "fsbp_iam_21_no_wildcard_actions_customer_policies" {
  locals {
    parsed     = core::jsondecode(core::try(attrs.policy, "{}"))
    statements = core::try(local.parsed.Statement, [])

    wildcard_actions = core::flatten([
      for s in local.statements : [
        for a in core::flatten([core::try(s.Action, [])]) : a
        if core::endswith(core::try(a, ""), ":*") || core::try(a, "") == "*"
      ]
      if core::try(s.Effect, "") == "Allow"
    ])
  }

  enforce {
    condition     = core::length(local.wildcard_actions) == 0
    error_message = "IAM.21: wildcard actions are not allowed (found: ${core::join(", ", local.wildcard_actions)})"
  }
}
