# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP RDS.3 — RDS DB instances should have encryption at rest enabled
# (storage_encrypted = true AND kms_key_id, if set, must reference a
#  customer-managed key listed via getresources of aws_kms_key)
# -----------------------------------------------------------------------------
# Combines: input + core::getresources + null-handling + core::contains
# =============================================================================

policy {
}

input "required_kms_alias_prefix" {
  type    = string
  default = "alias/data-"
}

resource_policy "aws_db_instance" "fsbp_rds_3_encryption_at_rest" {
  locals {
    id          = core::try(attrs.identifier, "<unnamed>")
    encrypted   = core::try(attrs.storage_encrypted, false)
    kms_id      = core::try(attrs.kms_key_id, null)
    all_keys    = core::getresources("aws_kms_key", {})
    matching    = local.kms_id == null ? [] : [
      for k in local.all_keys : k
      if core::try(k.arn, "") == local.kms_id ||
         core::try(k.key_id, "") == local.kms_id
    ]
  }

  enforce {
    condition     = local.encrypted
    error_message = "RDS.3: storage_encrypted must be true on '${local.id}'"
  }

  enforce {
    condition     = local.kms_id == null || core::length(local.matching) > 0
    error_message = "RDS.3: kms_key_id on '${local.id}' must resolve to a known aws_kms_key (prefix '${input.required_kms_alias_prefix}')"
  }
}
