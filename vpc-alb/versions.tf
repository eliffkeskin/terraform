terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"

  backend "s3" {
    bucket = "elif-tfstate-xxx"
    key = "vpc-alb/terraform.tfstate"
    region = "eu-central-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "eu-central-1"
}