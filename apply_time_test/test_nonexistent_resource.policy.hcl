# Test policy for Row 33: Targets a resource type that doesn't exist in the configuration
# This policy targets aws_lambda_function, which is NOT in the main.tf

resource_policy "aws_lambda_function" "test_nonexistent_resource" {
  enforcement_level = "advisory"
  
  locals {
    function_name = core::try(attrs.function_name, "unknown")
  }
  
  enforce {
    condition = true
    info_message = "✅ Lambda function validation passed: ${local.function_name}"
    error_message = "❌ Lambda function validation failed"
  }
}