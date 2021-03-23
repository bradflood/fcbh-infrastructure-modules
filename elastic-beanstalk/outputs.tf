# beanstalk outputs
output "elastic_beanstalk_application_name" {
  value       = module.elastic_beanstalk_application.elastic_beanstalk_application_name
  description = "Elastic Beanstalk Application name"
}

output "elastic_beanstalk_environment_hostname" {
  value       = module.elastic_beanstalk_environment.hostname
  description = "DNS hostname"
}

output "elastic_beanstalk_environment_id" {
  description = "ID of the Elastic Beanstalk environment"
  value       = module.elastic_beanstalk_environment.id
}

output "elastic_beanstalk_environment_name" {
  value       = module.elastic_beanstalk_environment.name
  description = "Name"
}
output "elastic_beanstalk_environment_application" {
  description = "The Elastic Beanstalk Application specified for this environment"
  value       = module.elastic_beanstalk_environment.application
}

output "elastic_beanstalk_environment_setting" {
  description = "Settings specifically set for this environment"
  value       = module.elastic_beanstalk_environment.setting
}

output "elastic_beanstalk_environment_all_settings" {
  description = "List of all option settings configured in the environment. These are a combination of default settings and their overrides from setting in the configuration"
  value       = module.elastic_beanstalk_environment.all_settings
}

output "elastic_beanstalk_environment_endpoint" {
  description = "Fully qualified DNS name for the environment"
  value       = module.elastic_beanstalk_environment.endpoint
}

output "elastic_beanstalk_environment_autoscaling_groups" {
  description = "The autoscaling groups used by this environment"
  value       = module.elastic_beanstalk_environment.autoscaling_groups
}

output "elastic_beanstalk_environment_instances" {
  description = "Instances used by this environment"
  value       = module.elastic_beanstalk_environment.instances
}

output "elastic_beanstalk_environment_launch_configurations" {
  description = "Launch configurations in use by this environment"
  value       = module.elastic_beanstalk_environment.launch_configurations
}

output "elastic_beanstalk_environment_load_balancers" {
  description = "Elastic Load Balancers in use by this environment"
  value       = module.elastic_beanstalk_environment.load_balancers
}

output "elastic_beanstalk_environment_triggers" {
  description = "Autoscaling triggers in use by this environment"
  value       = module.elastic_beanstalk_environment.triggers
}

output "zone_id" {
  value = var.dns_zone_id
}
