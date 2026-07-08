# Test policy for Row 39: References a workspace tag that doesn't exist
# This policy references meta.tfe_workspace.tags.cost_center which is NOT set on the workspace

resource_policy "aws_s3_bucket" "test_missing_workspace_tag" {
  enforcement_level = "advisory"
  
  locals {
    # Reference a tag that doesn't exist on the workspace
    cost_center = meta.tfe_workspace.tags.cost_center
    project_id = meta.tfe_workspace.tags.project_id
  }
  
  enforce {
    # Check if cost_center tag is set
    condition = local.cost_center != null && local.cost_center != ""
    info_message = "✅ Cost center tag found: ${local.cost_center}"
    error_message = "❌ Cost center tag is missing or empty (value: '${local.cost_center}')"
  }
  
  enforce {
    # Check if project_id tag is set
    condition = local.project_id != null && local.project_id != ""
    info_message = "✅ Project ID tag found: ${local.project_id}"
    error_message = "❌ Project ID tag is missing or empty (value: '${local.project_id}')"
  }
}