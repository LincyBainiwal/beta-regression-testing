# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP RDS.13 — RDS automatic minor version upgrades should be enabled
# (either auto_minor_version_upgrade = true, OR the engine_version is already
#  at or above a minimum semver constraint)
# -----------------------------------------------------------------------------
# Combines: core::semverconstraint + meta + ternary
# =============================================================================

policy {
}

resource_policy "aws_db_instance" "fsbp_rds_13_minor_version_upgrades" {
  locals {
    id              = core::try(attrs.identifier, "<unnamed>")
    auto_upgrade    = core::try(attrs.auto_minor_version_upgrade, null)
    engine          = core::try(attrs.engine, "unknown")
    engine_version  = core::try(attrs.engine_version, "0.0.0")
    meets_floor     = core::semverconstraint(local.engine_version, ">= 15.0.0")
    is_compliant    = local.auto_upgrade == true ? true : local.meets_floor
  }

  enforce {
    condition     = local.is_compliant
    error_message = "RDS.13: '${local.id}' engine ${local.engine} ${local.engine_version} must enable auto_minor_version_upgrade or meet floor >= 15.0.0"
  }
}
