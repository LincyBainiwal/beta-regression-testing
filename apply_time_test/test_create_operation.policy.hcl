# Test policy for Row 35: Targets CREATE operation
# This policy only evaluates when resources are being created

resource_policy "aws_s3_bucket" "test_create_operation" {
  enforcement_level = "advisory"
  operations = ["create"]
  
  locals {
    bucket_name = core::try(attrs.bucket, "unknown")
  }
  
  enforce {
    condition = true
    info_message = "✅ CREATE operation detected for bucket: ${local.bucket_name}"
    error_message = "❌ CREATE operation validation failed"
  }
}