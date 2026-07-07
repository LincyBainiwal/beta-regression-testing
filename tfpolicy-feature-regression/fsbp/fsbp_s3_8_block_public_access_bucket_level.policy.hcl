# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP S3.8 — S3 Block Public Access should be enabled at the bucket level
# (target the aws_s3_bucket_public_access_block resource directly; all four
#  flags must be true)
# -----------------------------------------------------------------------------
# Combines: multiple enforce blocks + core::try + null-handling
# =============================================================================

policy {
}

resource_policy "aws_s3_bucket_public_access_block" "fsbp_s3_8_block_public_access_bucket_level" {
  enforce {
    condition     = core::try(attrs.block_public_acls, null) == true
    error_message = "S3.8: block_public_acls must be true"
  }

  enforce {
    condition     = core::try(attrs.block_public_policy, null) == true
    error_message = "S3.8: block_public_policy must be true"
  }

  enforce {
    condition     = core::try(attrs.ignore_public_acls, null) == true
    error_message = "S3.8: ignore_public_acls must be true"
  }

  enforce {
    condition     = core::try(attrs.restrict_public_buckets, null) == true
    error_message = "S3.8: restrict_public_buckets must be true"
  }
}
