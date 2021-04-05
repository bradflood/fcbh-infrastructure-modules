
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

# 2. Create organization unit. 
resource "aws_organizations_organizational_unit" "org_unit" {
  name      = var.organization_unit_name
  parent_id = var.organization_id
}
#terragrunt import aws_organizations_organizational_unit.org_unit 