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


module "acm_request_certificate" {
  source                    = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate.git?ref=tags/0.10.0"
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method
  tags                      = var.tags
}
