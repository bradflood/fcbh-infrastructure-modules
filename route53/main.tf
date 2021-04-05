terraform {
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

module "route53_zone" {
  source                     = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-zone.git?ref=tags/0.11.0"
  namespace                  = var.namespace
  stage                      = var.stage
  name                       = var.name
  attributes                 = var.attributes
  tags                       = var.tags
  zone_name                  = var.zone_name
  parent_zone_name           = var.parent_zone_name
  parent_zone_record_enabled = var.parent_zone_record_enabled
}