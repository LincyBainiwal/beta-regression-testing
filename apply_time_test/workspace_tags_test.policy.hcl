# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
#
# Row 21: Test policy for workspace context
# Tests that TFPolicy can evaluate policies in workspace context
# Note: meta.tfe_workspace may not be available in current TFPolicy beta

resource_policy "aws_s3_bucket" "workspace_context_validation" {
  enforcement_level = "advisory"
  
  locals {
    # Get all S3 buckets for validation
    s3_buckets = core::getresources("aws_s3_bucket")
  }
  
  # Enforce block: Validate S3 buckets exist in workspace
  enforce {
    condition = length(local.s3_buckets) > 0
    
    info_message = "✅ Workspace validation PASSED: Found ${length(local.s3_buckets)} S3 bucket(s) in workspace configuration"
    
    error_message = "❌ Workspace validation FAILED: No S3 buckets found in workspace"
  }
  
  # Enforce block: Log bucket information
  enforce {
    condition = true  # Always pass, just for logging
    
    info_message = "📋 Workspace Context: Evaluating ${length(local.s3_buckets)} S3 bucket resource(s) in this workspace run"
  }
}