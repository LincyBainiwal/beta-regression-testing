# Test policy for Row 38: Mandatory-overridable enforcement level
# This policy will fail and require override to proceed

resource_policy "aws_s3_bucket" "test_mandatory_overridable" {
  enforcement_level = "mandatory"  # This will block the run unless overridden
  
  locals {
    bucket_name = core::try(attrs.bucket, "unknown")
  }
  
  enforce {
    condition = false  # Always fails - requires override
    info_message = "This should not show"
    error_message = "🚫 MANDATORY: This policy requires override to proceed. Bucket: ${local.bucket_name}"
  }
}