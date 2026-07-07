# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP KMS.4 — AWS KMS key rotation should be enabled
# (skipped for asymmetric keys, which cannot rotate)
# -----------------------------------------------------------------------------
# Combines: locals + ternary + core::contains + filter (via condition)
# =============================================================================

policy {
}

resource_policy "aws_kms_key" "fsbp_kms_4_rotation_enabled" {
  locals {
    spec               = core::try(attrs.customer_master_key_spec, "SYMMETRIC_DEFAULT")
    asymmetric_specs   = ["RSA_2048", "RSA_3072", "RSA_4096", "ECC_NIST_P256", "ECC_NIST_P384", "ECC_NIST_P521", "ECC_SECG_P256K1"]
    is_asymmetric      = core::contains(local.asymmetric_specs, local.spec)
    rotation_enabled   = core::try(attrs.enable_key_rotation, false)
    is_compliant       = local.is_asymmetric ? true : local.rotation_enabled
  }

  enforce {
    condition     = local.is_compliant
    error_message = "KMS.4: symmetric KMS key must set enable_key_rotation = true (spec=${local.spec})"
  }
}
