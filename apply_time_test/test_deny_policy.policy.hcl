# Test policy that will FAIL (deny result)
resource_policy "aws_s3_bucket" "test_deny_policy" {
  enforcement_level = "advisory"
  
  enforce {
    condition = false  # Always fails
    info_message = "This should never show"
    error_message = "❌ DENY: This policy always fails (advisory - run will proceed)"
  }
}