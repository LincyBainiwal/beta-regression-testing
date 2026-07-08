# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
#
# Row 21: Test policy that validates workspace tags
# Tests that TFPolicy can access and evaluate workspace tags

resource_policy "aws_s3_bucket" "workspace_tags_validation" {
  enforcement_level = "advisory"
  
  locals {
    # Access workspace tags using meta.tfe_workspace.tags
    workspace_env = meta.tfe_workspace.tags.environment
    workspace_compliance = meta.tfe_workspace.tags.compliance
    workspace_team = meta.tfe_workspace.tags.team
  }
  
  # Enforce block 1: Check environment tag
  enforce {
    condition = local.workspace_env == "staging"
    
    info_message = "✅ Environment tag validation PASSED: workspace is tagged as '${local.workspace_env}'"
    
    error_message = "❌ Environment tag validation FAILED: expected 'staging', got '${local.workspace_env}'"
  }
  
  # Enforce block 2: Check compliance tag
  enforce {
    condition = local.workspace_compliance == "required"
    
    info_message = "✅ Compliance tag validation PASSED: compliance is '${local.workspace_compliance}'"
    
    error_message = "❌ Compliance tag validation FAILED: expected 'required', got '${local.workspace_compliance}'"
  }
  
  # Enforce block 3: Check team tag exists
  enforce {
    condition = local.workspace_team != null && local.workspace_team != ""
    
    info_message = "✅ Team tag validation PASSED: team is '${local.workspace_team}'"
    
    error_message = "❌ Team tag validation FAILED: team tag is missing or empty"
  }
  
  # Enforce block 4: Log all tag values for verification
  enforce {
    condition = true  # Always pass, just for logging
    
    info_message = "📋 Workspace Tags Summary: environment='${local.workspace_env}', compliance='${local.workspace_compliance}', team='${local.workspace_team}'"
  }
}