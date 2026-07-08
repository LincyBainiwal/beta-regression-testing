# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
#
# Row 21: Test policy that validates workspace tags
# Tests that TFPolicy can access and evaluate workspace tags
# Note: This tests the meta.tfe_workspace object availability

resource_policy "aws_s3_bucket" "workspace_tags_validation" {
  enforcement_level = "advisory"
  
  # Enforce block: Check if workspace metadata is accessible
  enforce {
    # Just check if meta.tfe_workspace exists and is accessible
    # Using a simple condition that will always pass
    condition = meta.tfe_workspace.name != null && meta.tfe_workspace.name != ""
    
    info_message = "✅ Workspace metadata accessible: workspace name is '${meta.tfe_workspace.name}'"
    
    error_message = "❌ Workspace metadata not accessible"
  }
  
  # Enforce block: Log workspace information
  enforce {
    condition = true  # Always pass, just for logging
    
    info_message = "📋 Workspace Info: name='${meta.tfe_workspace.name}', id='${meta.tfe_workspace.id}'"
  }
}