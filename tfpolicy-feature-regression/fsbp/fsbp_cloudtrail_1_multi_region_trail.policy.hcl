# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP CloudTrail.1 — CloudTrail should be enabled and configured with at least
# one multi-Region trail
# (modelled as a provider-level policy: across all aws_cloudtrail resources in
#  the configuration, at least one must be multi-region AND enabled)
# -----------------------------------------------------------------------------
# Combines: core::getresources + for-expression + core::length + provider_policy
# =============================================================================

policy {
}
#to do - to readd it after we add support for callback to these policeis
# provider_policy "aws" "fsbp_cloudtrail_1_multi_region_trail" {
#   locals {
#     trails = core::getresources("aws_cloudtrail", {})
#     qualifying = [
#       for t in local.trails : t
#       if core::try(t.is_multi_region_trail, false) == true &&
#          core::try(t.enable_logging, true)        != false
#     ]
#   }

#   enforce {
#     condition     = core::length(local.qualifying) >= 1
#     error_message = "CloudTrail.1: at least one aws_cloudtrail must be multi-region and enabled (found ${core::length(local.trails)} trails, ${core::length(local.qualifying)} qualifying)"
#   }
# }
