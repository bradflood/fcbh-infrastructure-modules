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

data "aws_availability_zones" "all" {
  state = "available"
}


module "memcached" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-elasticache-memcached.git?ref=tags/0.6.0"
  namespace                    = var.namespace
  stage                        = var.stage
  name                         = "cache"
  availability_zones           = data.aws_availability_zones.all.names
  vpc_id                       = var.vpc_id
  allowed_security_groups      = var.allowed_security_groups
  subnets                      = var.private_subnets
  cluster_size                 = var.cluster_size
  instance_type                = var.memcached_instance_type
  engine_version               = var.engine_version
  apply_immediately            = true
  zone_id                      = var.zone_id
}