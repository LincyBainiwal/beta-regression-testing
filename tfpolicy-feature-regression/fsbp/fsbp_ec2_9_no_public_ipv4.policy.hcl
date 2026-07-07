# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP EC2.9 — EC2 instances should not have a public IPv4 address
# (instances must set associate_public_ip_address = false, unless the instance
#  name is in an explicit allowlist input)
# -----------------------------------------------------------------------------
# Combines: input block + ternary + null-handling + core::contains
# =============================================================================

policy {
}

input "allowlisted_instance_names" {
  type    = list(string)
  default = []
}

resource_policy "aws_instance" "fsbp_ec2_9_no_public_ipv4" {
  locals {
    name         = core::try(attrs.tags[0].Name, "<unnamed>")
    public_ip    = core::try(attrs.associate_public_ip_address, null)
    is_exempt    = core::contains(input.allowlisted_instance_names, local.name)
    has_public   = local.public_ip == true
    is_compliant = local.is_exempt ? true : !local.has_public
  }

  enforce {
    condition     = local.is_compliant
    error_message = "EC2.9: instance '${local.name}' has a public IPv4 address (allowlist it via 'allowlisted_instance_names' if intentional)"
  }
}
