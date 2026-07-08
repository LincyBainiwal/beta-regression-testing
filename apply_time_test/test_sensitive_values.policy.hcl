# Test policy for Row 40: Sensitive-looking values in messages
# This policy includes values that might be sensitive in its messages

resource_policy "aws_s3_bucket" "test_sensitive_values" {
  enforcement_level = "advisory"
  
  locals {
    bucket_name = core::try(attrs.bucket, "unknown")
    # Simulate accessing potentially sensitive data
    bucket_arn = core::try(attrs.arn, "unknown")
    tags = core::try(attrs.tags, {})
  }
  
  enforce {
    condition = true
    # Include bucket details in the message - these should be handled appropriately
    info_message = "✅ Bucket validation passed. Details: name=${local.bucket_name}, arn=${local.bucket_arn}, tags=${core::jsonencode(local.tags)}"
    error_message = "❌ Bucket validation failed. Details: name=${local.bucket_name}, arn=${local.bucket_arn}"
  }
}