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

# follow https://github.com/cloudposse/terraform-aws-rds-cluster/issues/63. when incorporated, change cluster size back to 1

module "rds_cluster_aurora_mysql" {
  source         = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=tags/0.31.0"
  engine         = var.engine
  engine_version = var.engine_version
  cluster_family = var.cluster_family
  cluster_size   = var.cluster_size
  namespace      = var.namespace
  stage          = var.stage
  name           = var.name
  admin_user     = "sa"
  admin_password = "Test123456789"
  # db_name                      = var.db_name # for DBP, database name is provided as env var. 
  instance_type                = var.instance_type
  snapshot_identifier          = var.snapshot_identifier
  vpc_id                       = var.vpc_id
  security_groups              = var.security_groups
  subnets                      = var.subnets
  zone_id                      = var.zone_id
  autoscaling_enabled          = var.autoscaling_enabled
  autoscaling_min_capacity     = var.autoscaling_min_capacity
  autoscaling_policy_type      = var.autoscaling_policy_type
  autoscaling_target_metrics   = var.autoscaling_target_metrics
  autoscaling_target_value     = var.autoscaling_target_value
  performance_insights_enabled = var.performance_insights_enabled


  cluster_parameters = [
    {
      name         = "binlog_format"
      value        = "row"
      apply_method = "pending-reboot"
    }
  ]
}
