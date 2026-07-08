# Test policy that will ERROR (setup error or unknown result)
resource_policy "aws_s3_bucket" "test_error_policy" {
  enforcement_level = "advisory"
  
  locals {
    # This will cause an error by trying to access a non-existent attribute
    test_value = attrs.non_existent_attribute_that_causes_error
  }
  
  enforce {
    condition = local.test_value == "something"
    info_message = "This should never show"
    error_message = "⚠️ ERROR: This policy has a setup error"
  }
}