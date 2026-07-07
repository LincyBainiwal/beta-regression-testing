# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP S3.5 — S3 buckets should require requests to use Secure Socket Layer (TLS)
# (the bucket policy must contain a Deny statement with
#  Condition.Bool.aws:SecureTransport = false)
# -----------------------------------------------------------------------------
# Combines: core::jsondecode + for-expression + core::contains + locals + attrs
# =============================================================================

policy {
}

resource_policy "aws_s3_bucket_policy" "fsbp_s3_5_ssl_only_bucket_policy" {
  locals {
    raw         = core::try(attrs.policy, "{}")
    parsed      = core::jsondecode(local.raw)
    statements  = core::try(local.parsed.Statement, [])

    has_ssl_only = core::length([
      for s in local.statements : s
      if core::try(s.Effect, "") == "Deny" &&
         core::try(s.Condition.Bool["aws:SecureTransport"], "true") == "false"
    ]) > 0
  }

  enforce {
    condition     = local.has_ssl_only
    error_message = "S3.5: bucket policy must Deny non-TLS access (aws:SecureTransport = false)"
  }
}
