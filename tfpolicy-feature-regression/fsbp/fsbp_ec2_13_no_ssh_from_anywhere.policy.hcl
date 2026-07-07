# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP EC2.13 — Security groups should not allow ingress from 0.0.0.0/0 to port 22
# (also flags port 3389 — RDP — in a second enforce block)
# -----------------------------------------------------------------------------
# Combines: for-expression + core::contains + multiple enforce blocks + locals
# =============================================================================

policy {
}

resource_policy "aws_security_group" "fsbp_ec2_13_no_ssh_from_anywhere" {
  locals {
    ingress = core::try(attrs.ingress, [])

    open_ssh_rules = [
      for r in local.ingress : r
      if core::try(r.from_port, -1) <= 22 &&
         core::try(r.to_port, -1)   >= 22 &&
         core::contains(core::try(r.cidr_blocks, []), "0.0.0.0/0")
    ]

    open_rdp_rules = [
      for r in local.ingress : r
      if core::try(r.from_port, -1) <= 3389 &&
         core::try(r.to_port, -1)   >= 3389 &&
         core::contains(core::try(r.cidr_blocks, []), "0.0.0.0/0")
    ]
  }

  enforce {
    condition     = core::length(local.open_ssh_rules) == 0
    error_message = "EC2.13: security group must not allow 0.0.0.0/0 → port 22 (SSH)"
  }

  enforce {
    condition     = core::length(local.open_rdp_rules) == 0
    error_message = "EC2.13: security group must not allow 0.0.0.0/0 → port 3389 (RDP)"
  }
}
