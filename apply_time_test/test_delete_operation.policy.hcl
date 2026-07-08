# Test policy for Row 35: Targets DELETE operation
# This policy only evaluates when resources are being deleted/destroyed

resource_policy "aws_s3_bucket" "test_delete_operation" {
  enforcement_level = "advisory"
  operations = ["delete"]
  
  locals {
    bucket_name = core::try(attrs.bucket, "unknown")
  }
  
  enforce {
    condition = true
    info_message = "✅ DELETE operation detected for bucket: ${local.bucket_name}"
    error_message = "❌ DELETE operation validation failed"
  }
}