# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP CloudTrail.2 — CloudTrail should have encryption at-rest enabled
# (each aws_cloudtrail must reference a KMS key, and that key must exist in the
#  configuration as an aws_kms_key resource)
# -----------------------------------------------------------------------------
# Combines: core::getresources + multiple enforce blocks + null-handling
# =============================================================================

policy {
}

resource_policy "aws_cloudtrail" "fsbp_cloudtrail_2_encryption_at_rest" {
  locals {
    trail_name = core::try(attrs.name, "<unnamed>")
    kms_id     = core::try(attrs.kms_key_id, null)
    all_keys   = core::getresources("aws_kms_key", {})
    resolves   = local.kms_id == null ? [] : [
      for k in local.all_keys : k
      if core::try(k.arn, "") == local.kms_id ||
         core::try(k.key_id, "") == local.kms_id
    ]
  }

  enforce {
    condition     = local.kms_id != null && local.kms_id != ""
    error_message = "CloudTrail.2: trail '${local.trail_name}' must set kms_key_id"
  }

  enforce {
    condition     = local.kms_id == null || core::length(local.resolves) > 0
    error_message = "CloudTrail.2: kms_key_id on trail '${local.trail_name}' must reference an aws_kms_key in the configuration"
  }
}
