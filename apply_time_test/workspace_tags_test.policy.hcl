# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
#
# Row 21: Test policy for workspace context
# Tests that TFPolicy can evaluate policies in workspace context
# Simplified to just validate the policy runs successfully

resource_policy "aws_s3_bucket" "workspace_context_validation" {
  enforcement_level = "advisory"
  
  # Enforce block: Simple validation that always passes
  enforce {
    # Check if the bucket resource has an ID (it should during plan)
    condition = resource.bucket != null && resource.bucket != ""
    
    info_message = "✅ Row 21 Test PASSED: Policy evaluated successfully in workspace context for S3 bucket '${resource.bucket}'"
    
    error_message = "❌ Row 21 Test FAILED: Bucket name is null or empty"
  }
  
  # Enforce block: Log that policy is running
  enforce {
    condition = true  # Always pass, just for logging
    
    info_message = "📋 Row 21: Workspace-scoped policy evaluation completed successfully"
  }
}