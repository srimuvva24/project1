provider "aws" {
  region = var.aws_region
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "tf-sanity-test-bucket-${random_id.bucket_suffix.hex}"
  acl    = "private"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

output "bucket_name" {
  value = aws_s3_bucket.test_bucket.id
}
