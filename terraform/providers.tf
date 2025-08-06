terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket         = "moabodaif-terraform-s3-backend"
    key            = "terraform/state"
    dynamodb_table = "backend-lock-table"
    region         = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
}
