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

data "aws_availability_zones" "available" {}

locals {
  max_availability_zones = 3
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.16.1"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  cidr_block = var.cidr_block
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.29.0"
  availability_zones  = slice(data.aws_availability_zones.available.names, 0, local.max_availability_zones)
  namespace           = var.namespace
  stage               = var.stage
  name                = var.name
  vpc_id              = module.vpc.vpc_id
  igw_id              = module.vpc.igw_id
  cidr_block          = module.vpc.vpc_cidr_block
  nat_gateway_enabled = "true"
}

# note convered to TF 0.12 yet
# module "flow_logs" {
#   source    = "git::https://github.com/cloudposse/terraform-aws-cloudwatch-flow-logs.git?ref=tags/0.4.0"
#   vpc_id    = module.vpc.vpc_id
#   namespace = var.namespace
#   stage     = var.stage
# }