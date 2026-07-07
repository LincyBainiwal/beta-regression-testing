# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP S3.14 — S3 buckets should use versioning
# (every aws_s3_bucket must have a sibling aws_s3_bucket_versioning resource
#  whose versioning_configuration.status is "Enabled")
# -----------------------------------------------------------------------------
# Combines: locals + ternary + meta reference + core::getresources
# =============================================================================

policy {
}

resource_policy "aws_s3_bucket" "fsbp_s3_14_versioning_enabled" {
  enforcement_level = "mandatory_overridable"
  locals {
    bucket_name = core::try(attrs.bucket, "")
    versionings = core::getresources("aws_s3_bucket_versioning", { bucket = local.bucket_name })
    status      = core::length(local.versionings) > 0 ? core::try(local.versionings[0].versioning_configuration[0].status, "Disabled") : "Disabled"
  }

  enforce {
    condition     = local.status == "Enabled"
    error_message = "S3.14: bucket '${local.bucket_name}' versioning status is '${local.status}', expected 'Enabled' (provider: ${core::try(meta.provider_type, "?")})"
  }
}
