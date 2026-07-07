# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

variable "name" {
  type = string
}

variable "bucket_suffix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_s3_bucket" "in_module" {
  bucket = "${var.name}-module-bucket-${var.bucket_suffix}"
  tags   = var.tags
}

output "bucket_id" {
  value = aws_s3_bucket.in_module.id
}
