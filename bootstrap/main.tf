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

resource "aws_s3_bucket" "elif-tfstate-xxx" {
  bucket = "elif-tfstate-xxx"

  tags = {
    Name = "elif-tfstate-xxx"
  }
}

resource "aws_s3_bucket_versioning" "elif-tfstate-xxx-versioning" {
  bucket = aws_s3_bucket.elif-tfstate-xxx.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "elif-tfstate-xxx-public-access-block" {
  bucket = aws_s3_bucket.elif-tfstate-xxx.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_server_side_encryption_configuration" "elif-tfstate-xxx-server-side-encryption-configuration" {
  bucket = aws_s3_bucket.elif-tfstate-xxx.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}