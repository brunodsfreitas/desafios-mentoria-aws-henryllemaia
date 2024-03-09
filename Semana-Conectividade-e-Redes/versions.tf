terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39.1"
    }
  }
}

provider "aws" {
  region  = local.region
  profile = local.profile
}