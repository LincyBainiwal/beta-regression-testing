# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
#
# Exercises every target kind covered by both policy sets:
#   - policies/   (feature-regression: every language feature in isolation)
#   - fsbp/       (15 AWS Foundational Security Best Practices controls)
#
# Run `terraform plan` against this config with the policy plugin loaded to
# confirm every policy in either set has at least one resource to evaluate.

# =============================================================================
# S3 — covers feature-regression S3 targets and FSBP S3.1 / S3.5 / S3.8 / S3.14
# =============================================================================

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "regression" {
  bucket = "${var.bucket_prefix}regression-data-${random_id.bucket_suffix.hex}"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "regression" {
  bucket = aws_s3_bucket.regression.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "regression" {
  bucket                  = aws_s3_bucket.regression.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "regression" {
  bucket = aws_s3_bucket.regression.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.regression_data.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_metadata_configuration" "regression" {
  bucket = aws_s3_bucket.regression.id

  metadata_configuration {
    inventory_table_configuration {
      configuration_state = "DISABLED"
    }
    journal_table_configuration {
      record_expiration {
        expiration = "ENABLED"
        days       = 30
      }
    }
  }
}

resource "aws_s3_bucket_policy" "regression_tls_only" {
  bucket = aws_s3_bucket.regression.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.regression.arn,
        "${aws_s3_bucket.regression.arn}/*",
      ]
      Condition = {
        Bool = {
          "aws:SecureTransport" = "false"
        }
      }
    }]
  })
}

resource "aws_s3_bucket" "regression-fail" {
  bucket = "${var.bucket_prefix}regression-failing-bucket-${random_id.bucket_suffix.hex}"
  tags   = var.tags
}

# =============================================================================
# EC2 / networking — covers feature-regression resource targets and
#                    FSBP EC2.2 / EC2.9 / EC2.13
# =============================================================================

# resource "aws_default_security_group" "regression" {
#   # Intentionally empty — covers EC2.2 pass case
#   tags = var.tags
# }

# data "aws_ami" "amazon_linux_2_x86" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# resource "aws_instance" "regression" {
#   # Hardcoded AMI so `terraform plan` doesn't make a live EC2 DescribeImages
#   # call against AWS (the regression suite runs without real credentials).
#   ami                         = data.aws_ami.amazon_linux_2_x86.id
#   instance_type               = var.instance_type
#   associate_public_ip_address = false
#   tags                        = merge(var.tags, { Name = "regression-instance" })
# }

resource "aws_security_group" "regression" {
  name = "${var.bucket_prefix}regression"
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  tags = var.tags
}

# =============================================================================
# IAM — covers FSBP IAM.1 / IAM.21
# =============================================================================

resource "aws_iam_policy" "regression_scoped" {
  name = "${var.bucket_prefix}scoped-read"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = ["${aws_s3_bucket.regression.arn}/*"]
    }]
  })
}

# =============================================================================
# RDS — covers FSBP RDS.2 / RDS.3 / RDS.13
# =============================================================================

resource "aws_db_instance" "regression" {
  identifier                  = "${var.bucket_prefix}regression-db"
  engine                      = "postgres"
  engine_version              = "15.4"
  instance_class              = "db.t3.micro"
  allocated_storage           = 20
  username                    = "regression"
  password                    = "change-me-in-real-life"
  skip_final_snapshot         = true
  publicly_accessible         = false
  storage_encrypted           = true
  kms_key_id                  = aws_kms_key.regression_data.arn
  auto_minor_version_upgrade  = true
}

# =============================================================================
# KMS — covers FSBP KMS.4 (and supplies a key for RDS.3 / CloudTrail.2)
# =============================================================================

resource "aws_kms_key" "regression_data" {
  description              = "data-encryption key for regression policy set"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
}

# =============================================================================
# CloudTrail — covers FSBP CloudTrail.1 / CloudTrail.2
# =============================================================================

resource "aws_cloudtrail" "regression" {
  name                          = "${var.bucket_prefix}regression-trail"
  s3_bucket_name                = aws_s3_bucket.regression.id
  is_multi_region_trail         = true
  enable_logging                = true
  include_global_service_events = true
  kms_key_id                    = aws_kms_key.regression_data.arn
}

# =============================================================================
# (Data source removed — the regression suite runs without real AWS creds, so
# data "aws_ami" {...} would hit DescribeImages and 401. Data-source coverage
# lives in the unit suite: feature_func_core_getdatasource.policytest.hcl.)
# =============================================================================

# =============================================================================
# Module — covers feature-regression `module_policy` target
# =============================================================================

module "example" {
  source        = "./modules/example"
  name          = "${var.bucket_prefix}module-instance"
  bucket_suffix = random_id.bucket_suffix.hex
  tags          = var.tags
}
