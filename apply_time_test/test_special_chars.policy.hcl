# Test policy for Row 42: Special characters in policy name and messages
# This policy includes quotes, commas, unicode, and newline characters

resource_policy "aws_s3_bucket" "test_special_chars_policy" {
  enforcement_level = "advisory"
  
  locals {
    bucket_name = core::try(attrs.bucket, "unknown")
  }
  
  enforce {
    condition = true
    
    # Info message with special characters: quotes, commas, unicode, newlines
    info_message = <<-EOT
    ✅ SPECIAL CHARS TEST: Bucket "${local.bucket_name}" passed validation!
    
    Details with special characters:
    - Quotes: "double quotes", 'single quotes'
    - Commas: item1, item2, item3
    - Unicode: ✓ ✗ → ← ↑ ↓ ★ ♥ © ® ™ € £ ¥
    - Emoji: 🎉 🚀 ✨ 🔒 🛡️ ⚠️ ❌ ✅
    - Special: @#$%^&*()_+-=[]{}|;:,.<>?/~`
    - Newlines and tabs are preserved
    
    Status: "PASSED" (with quotes)
    EOT
    
    # Error message with special characters
    error_message = <<-EOT
    ❌ SPECIAL CHARS ERROR: Bucket "${local.bucket_name}" failed!
    
    Issues found:
    1. Missing "encryption" setting
    2. Tags contain: 'env', 'team', 'cost-center'
    3. Unicode characters: ñ, é, ü, 中文, 日本語, 한글
    4. Special symbols: @, #, $, %, &, *, (, ), [, ], {, }
    
    Error code: "ERR-001" (quoted)
    EOT
  }
}