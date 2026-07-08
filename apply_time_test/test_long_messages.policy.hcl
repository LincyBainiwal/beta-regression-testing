# Test policy for Row 41: Long error and info messages
# This policy has intentionally long messages to test UI rendering

resource_policy "aws_s3_bucket" "test_long_messages" {
  enforcement_level = "advisory"
  
  locals {
    bucket_name = core::try(attrs.bucket, "unknown")
  }
  
  enforce {
    condition = false  # Force failure to show error message
    
    # Very long info message (this won't show since condition is false, but included for completeness)
    info_message = "✅ LONG INFO MESSAGE: This is a very long informational message that tests how the UI handles extensive text content. It includes multiple sentences to simulate real-world scenarios where policy authors might want to provide detailed explanations. The bucket name is ${local.bucket_name}. This message continues with more details about the validation process, including information about compliance requirements, security best practices, and organizational policies. It also includes technical details about the resource configuration, potential risks, and recommended actions. The message should be readable in the UI without breaking the layout, and it should be properly truncated or scrollable if needed. Additional context: This policy is part of a comprehensive security framework that ensures all S3 buckets meet organizational standards for data protection, access control, and audit logging. The validation checks multiple aspects of the bucket configuration including encryption settings, public access blocks, versioning, and lifecycle policies."
    
    # Very long error message
    error_message = "❌ LONG ERROR MESSAGE: This S3 bucket '${local.bucket_name}' has failed validation due to multiple policy violations. This is an intentionally long error message designed to test how the Terraform Cloud UI handles extensive error text. The message includes detailed information about what went wrong and how to fix it. Specific issues identified: 1) The bucket does not have encryption enabled at rest, which violates our data protection policy. All S3 buckets must use AES-256 or AWS KMS encryption. 2) Public access block settings are not configured correctly. The bucket should have all four public access block settings enabled (BlockPublicAcls, IgnorePublicAcls, BlockPublicPolicy, RestrictPublicBuckets). 3) Versioning is not enabled, which is required for data recovery and audit purposes. 4) The bucket does not have a lifecycle policy configured for cost optimization. 5) Logging is not enabled for audit trail purposes. To remediate these issues, please update your Terraform configuration to include the following resources: aws_s3_bucket_server_side_encryption_configuration, aws_s3_bucket_public_access_block, aws_s3_bucket_versioning, aws_s3_bucket_lifecycle_configuration, and aws_s3_bucket_logging. For more information, refer to our internal documentation at https://docs.example.com/s3-security-standards or contact the security team at security@example.com. This policy is enforced at the advisory level, so your run will proceed, but please address these issues as soon as possible to maintain compliance with organizational security standards."
  }
}