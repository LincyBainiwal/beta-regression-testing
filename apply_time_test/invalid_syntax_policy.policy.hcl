# Test policy with INVALID SYNTAX for row 31 testing
# This policy has intentional syntax errors

resource_policy "aws_s3_bucket" "invalid_syntax_test" {
  enforcement_level = "advisory"
  
  # Missing closing brace for locals block - SYNTAX ERROR
  locals {
    bucket_name = attrs.bucket
  # Missing closing brace here
  
  enforce {
    condition = true
    info_message = "This should not evaluate"
    error_message = "This policy has invalid syntax"
  }
}