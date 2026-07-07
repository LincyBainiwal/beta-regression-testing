variable "region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_prefix" {
  type    = string
  default = "test-"
}

variable "tags" {
  type    = map(string)
  default = {
    env   = "apply-time-test"
    owner = "team-platform"
  }
}
