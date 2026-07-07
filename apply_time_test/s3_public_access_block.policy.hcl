# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
#
# Apply-time policy: checks S3 bucket public access block using core::getresources
# core::getresources is an apply-time function — it fetches sibling resources
# from the current plan/state to validate cross-resource relationships.

resource_policy "aws_s3_bucket" "s3_public_access_block_required" {
  enforcement_level = "advisory"
  
  locals {
    bucket_id = core::try(attrs.id, attrs.bucket, "")

    # core::getresources fetches all aws_s3_bucket_public_access_block resources
    # empty filter = match all (avoids unknown bucket id at plan time)
    public_access_blocks = core::getresources(
      "aws_s3_bucket_public_access_block",
      {}
    )

    has_block            = core::length(local.public_access_blocks) > 0
    block                = local.has_block ? local.public_access_blocks[0] : null
    is_fully_blocked     = local.has_block ? (
      core::try(local.block.block_public_acls, false) == true &&
      core::try(local.block.block_public_policy, false) == true &&
      core::try(local.block.ignore_public_acls, false) == true &&
      core::try(local.block.restrict_public_buckets, false) == true
    ) : false
  }

  enforce {
    condition     = false  # Force policy to fail for testing
    info_message  = "S3 bucket '${local.bucket_id}' has public access fully blocked ✓"
    error_message = "⚠️ WARNING: S3 bucket '${local.bucket_id}' should have all public access block settings enabled (advisory - run will proceed)"
  }
}
