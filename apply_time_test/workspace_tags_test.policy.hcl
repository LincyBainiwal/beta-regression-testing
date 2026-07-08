# Test policy that uses workspace tags
resource_policy "aws_s3_bucket" "workspace_tags_validation" {
  enforcement_level = "advisory"
  
  locals {
    # Access workspace tags
    workspace_env = meta.tfe_workspace.tags.environment
    workspace_compliance = meta.tfe_workspace.tags.compliance
    workspace_team = meta.tfe_workspace.tags.team
  }
  
  enforce {
    # Check if environment tag equals "staging"
    condition = local.workspace_env == "staging"
    
    info_message = "✅ Environment tag validation: workspace is tagged as '${local.workspace_env}'"
    
    error_message = "❌ Environment tag mismatch: expected 'staging', got '${local.workspace_env}'"
  }
  
  enforce {
    # Check if compliance tag is set to "required"
    condition = local.workspace_compliance == "required"
    
    info_message = "✅ Compliance tag validation: compliance is '${local.workspace_compliance}'"
    
    error_message = "❌ Compliance tag issue: expected 'required', got '${local.workspace_compliance}'"
  }
  
  enforce {
    # Check if team tag is set
    condition = local.workspace_team != null && local.workspace_team != ""
    
    info_message = "✅ Team tag validation: team is '${local.workspace_team}'"
    
    error_message = "❌ Team tag missing or empty"
  }
}
