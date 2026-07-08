# Test policy that uses core::getdatasources
# This demonstrates the ability to fetch and validate data sources in the plan

resource_policy "aws_s3_bucket" "test_getdatasources" {
  enforcement_level = "advisory"
  
  locals {
    # Use core::getdatasources to fetch all aws_caller_identity data sources
    caller_identities = core::getdatasources(
      "aws_caller_identity",
      {}
    )
    
    has_caller_identity = core::length(local.caller_identities) > 0
    account_id = local.has_caller_identity ? core::try(local.caller_identities[0].account_id, "unknown") : "none"
  }
  
  enforce {
    condition = local.has_caller_identity
    info_message = "✅ GETDATASOURCES: Found AWS caller identity data source (Account: ${local.account_id})"
    error_message = "⚠️ GETDATASOURCES: No aws_caller_identity data source found in the plan"
  }
}