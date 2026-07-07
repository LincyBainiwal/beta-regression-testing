# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_prefix" {
  type    = string
  default = "prod-"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "tags" {
  type = map(string)
  default = {
    owner = "team-platform"
    env   = "regression"
  }
}
