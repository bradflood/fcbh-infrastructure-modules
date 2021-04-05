terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  required_version = "~> 0.12"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

# resource "aws_wafv2_web_acl" "rate-limit" {
#   name        = "rate-based-example"
#   description = "rate limit access"
#   scope       = "REGIONAL"

#   default_action {
#     block {}
#   }

#   rule {
#     name     = "rule-1"
#     priority = 1

#     action {
#       count {}
#     }

#     statement {
#       rate_based_statement {
#         limit              = 10000
#         aggregate_key_type = "IP"

#         scope_down_statement {
#           geo_match_statement {
#             country_codes = ["US", "NL"]
#           }
#         }
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = false
#       metric_name                = "friendly-rule-metric-name"
#       sampled_requests_enabled   = false
#     }
#   }

#   tags = {
#     Tag1 = "Value1"
#     Tag2 = "Value2"
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = false
#     metric_name                = "friendly-metric-name"
#     sampled_requests_enabled   = false
#   }
# }

