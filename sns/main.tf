terraform {
# Live modules pin exact Terraform version; generic modules let consumers pin the version.
# The latest version of Terragrunt (v0.19.0 and above) requires Terraform 0.12.0 or above.
   required_version = "~> 0.12"

# Live modules pin exact provider version; generic modules let consumers pin the version.
   required_providers {
      aws = {
         version = "~> 2.70"
      }
    }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  backend "s3" {}
  required_version = ">= 0.12.0"
}

# locals {
#    topic_name = join("", [var.topic, "-", module.label.id])
# }

# module "label" {
#   source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
#   namespace  = var.namespace
#   name       = var.name
#   stage      = var.stage
#   delimiter  = var.delimiter
#   attributes = var.attributes
#   tags       = var.tags
# }

# resource "aws_sns_topic" "default" {
#   name = local.topic_name
#   tags = module.label.tags
# }

module "sns" {
  source = "git::https://github.com/cloudposse/terraform-aws-sns-topic.git?ref=0.8.0"

  attributes = var.attributes
  name       = var.name
  namespace  = var.namespace
  stage      = var.stage

  # subscribers = {
  #   opsgenie = {
  #     protocol = "https"
  #     endpoint = "https://api.example.com/v1/"
  #     endpoint_auto_confirms = true
  #   }
  # }

  # sqs_dlq_enabled = false
}