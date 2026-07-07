# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# FSBP EC2.2 — VPC default security group should not allow inbound or outbound traffic
# -----------------------------------------------------------------------------
# Combines: filter + for-expression + splat + core::length
# =============================================================================

policy {
}

resource_policy "aws_default_security_group" "fsbp_ec2_2_default_sg_no_traffic" {
  # Only evaluate default SG resources (skip everything else trivially)
  filter = core::try(meta.provider_type, "") == "aws"

  locals {
    ingress_count = core::length(core::try(attrs.ingress[*].from_port, []))
    egress_count  = core::length(core::try(attrs.egress[*].from_port, []))
  }

  enforce {
    condition     = local.ingress_count == 0 && local.egress_count == 0
    error_message = "EC2.2: default security group must have no ingress (${local.ingress_count}) or egress (${local.egress_count}) rules"
  }
}
