# Test policy that will show UNKNOWN result (for testing purposes)
resource_policy "aws_s3_bucket" "test_error_policy" {
  enforcement_level = "advisory"
  
  locals {
    # Use a safe attribute access with try
    bucket_name = core::try(attrs.bucket, "unknown")
  }
  
  enforce {
    # This will pass for testing row 28
    condition = true
    info_message = "✅ Test policy for bucket: ${local.bucket_name}"
    error_message = "This should not show"
  }
}