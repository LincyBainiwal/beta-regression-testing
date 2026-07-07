# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP S3.1 — S3 Block Public Access should be enabled at the account level
# (modelled here as: every aws_s3_bucket must have a sibling
#  aws_s3_bucket_public_access_block resource with all four flags = true)
# -----------------------------------------------------------------------------
# Combines: locals + core::getresources + core::length + multiple enforce blocks
# =============================================================================

policy {
}

resource_policy "aws_s3_bucket" "fsbp_s3_1_block_public_access" {
  enforcement_level = "mandatory_overridable"
  locals {
    bucket_name = core::try(attrs.bucket, "")
    bpa_blocks  = core::getresources("aws_s3_bucket_public_access_block", { bucket = local.bucket_name })
    bpa        = core::length(local.bpa_blocks) > 0 ? local.bpa_blocks[0] : null
  }

  enforce {
    condition     = local.bpa != null
    error_message = "S3.1: bucket '${local.bucket_name}' has no aws_s3_bucket_public_access_block"
  }

  enforce {
    condition = local.bpa != null && (
      core::try(local.bpa.block_public_acls, false) &&
      core::try(local.bpa.block_public_policy, false) &&
      core::try(local.bpa.ignore_public_acls, false) &&
      core::try(local.bpa.restrict_public_buckets, false)
    )
    error_message = "S3.1: all four block-public-access flags must be true on '${local.bucket_name}'"
  }
}
