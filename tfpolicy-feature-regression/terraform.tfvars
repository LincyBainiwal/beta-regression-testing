# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

region        = "us-east-1"
bucket_prefix = "prod-"
instance_type = "t3.micro"
tags = {
  owner = "team-platform"
  env   = "regression"
}
