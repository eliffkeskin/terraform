terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "elif-tfstate-5247" {
  bucket = "elif-tfstate-5247"

  tags = {
    Name = "elif-tfstate-5247"
  }
}

resource "aws_s3_bucket_versioning" "elif-tfstate-5247-versioning" {
  bucket = aws_s3_bucket.elif-tfstate-5247.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "elif-tfstate-5247-public-access-block" {
  bucket = aws_s3_bucket.elif-tfstate-5247.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_server_side_encryption_configuration" "elif-tfstate-5247-server-side-encryption-configuration" {
  bucket = aws_s3_bucket.elif-tfstate-5247.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}