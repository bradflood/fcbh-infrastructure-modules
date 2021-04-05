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

module "elastic_beanstalk_application" {
  source      = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-application.git?ref=tags/0.8.0"
  namespace   = var.namespace
  stage       = var.stage
  name        = var.name
  attributes  = var.attributes
  tags        = var.tags
  description = var.application_description
}

module "elastic_beanstalk_environment" {
  source     = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment.git?ref=tags/0.38.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = var.attributes
  tags       = var.tags
  region     = var.aws_region

  additional_settings                = var.additional_settings
  vpc_id                             = var.vpc_id
  loadbalancer_subnets               = var.public_subnets
  application_subnets                = var.private_subnets
  allowed_security_groups            = var.allowed_security_groups
  additional_security_groups         = var.additional_security_groups
  description                        = var.environment_description
  dns_zone_id                        = var.dns_zone_id
  elastic_beanstalk_application_name = module.elastic_beanstalk_application.elastic_beanstalk_application_name
  enable_stream_logs                 = var.enable_stream_logs
  env_vars                           = var.env_vars
  environment_type                   = var.environment_type
  preferred_start_time               = var.preferred_start_time
  healthcheck_url                    = var.healthcheck_url
  instance_type                      = var.instance_type
  loadbalancer_certificate_arn       = var.loadbalancer_certificate_arn
  loadbalancer_ssl_policy            = "ELBSecurityPolicy-2016-08"
  loadbalancer_type                  = var.loadbalancer_type
  autoscale_min                      = var.autoscale_min
  autoscale_max                      = var.autoscale_max
  autoscale_upper_bound              = var.autoscale_upper_bound
  autoscale_lower_bound              = var.autoscale_lower_bound
  logs_retention_in_days             = var.logs_retention_in_days
  rolling_update_type                = var.rolling_update_type
  solution_stack_name                = var.solution_stack_name
  prefer_legacy_service_policy       = false
  keypair                            = var.keypair
  force_destroy                      = var.force_destroy # should be true ONLY for dev environments
}

# module "sns" {
#   source      = "../sns"
#   aws_region  = var.aws_region
#   aws_profile = var.aws_profile
#   namespace   = var.namespace
#   stage       = var.stage
#   name        = var.name
#   topic       = "beanstalk-environment-health"
# }


# resource "aws_cloudwatch_metric_alarm" "beanstalk-health" {
#   alarm_name                = join("-", ["beanstalk-health", module.elastic_beanstalk_environment.name])
#   metric_name               = "EnvironmentHealth"
#   namespace                 = "AWS/ElasticBeanstalk"
#   comparison_operator       = "GreaterThanThreshold"
#   threshold                 = "0"
#   evaluation_periods        = "1"
#   period                    = "300"
#   statistic                 = "Maximum"
#   alarm_description         = "This metric alarms on bad Beanstalk environment health"
#   alarm_actions             = [module.sns.arn]
#   insufficient_data_actions = []

#   dimensions = {
#     EnvironmentName = module.elastic_beanstalk_environment.name
#   }
# }
