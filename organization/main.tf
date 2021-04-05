
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  required_version = ">= 0.13"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

# 1. create organization for all things Digital Bible Platform
resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com"
  ]

  feature_set = "ALL"
}