# Test policy that will PASS (allow result)
resource_policy "aws_s3_bucket" "test_allow_policy" {
  enforcement_level = "advisory"
  
  enforce {
    condition = true  # Always passes
    info_message = "✅ ALLOW: This policy always passes"
    error_message = "This should never show"
  }
}