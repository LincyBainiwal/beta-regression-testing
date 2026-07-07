# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP RDS.2 — RDS DB instances should prohibit public access
# (publicly_accessible must be false; storage_encrypted should also be true here
#  for layered defence)
# -----------------------------------------------------------------------------
# Combines: multiple enforce blocks + meta reference + locals
# =============================================================================

policy {
}

resource_policy "aws_db_instance" "fsbp_rds_2_no_public_access" {
  locals {
    id            = core::try(attrs.identifier, "<unnamed>")
    publicly_acc  = core::try(attrs.publicly_accessible, null)
  }

  enforce {
    condition     = local.publicly_acc == false
    error_message = "RDS.2: db instance '${local.id}' (provider=${core::try(meta.provider_type, "?")}) must set publicly_accessible = false"
  }

  enforce {
    condition     = core::try(attrs.storage_encrypted, false) == true
    error_message = "RDS.2 (depth-in-defence): storage_encrypted must be true on '${local.id}'"
  }
}
