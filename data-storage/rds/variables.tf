variable "aws_region" {
}

variable "aws_profile" {
  type = string
}

variable "namespace" {
  description = "Namespace (e.g. `fcbh` )"
  type        = string
  default     = ""
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name  (e.g. `app` or `cluster`)"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}
variable "instance_type" {
  description = "Instance type to use"
  type        = string
  default     = "db.t3.micro"
}
variable "engine" {
  type        = string
  default     = "aurora-mysql"
  description = "The name of the database engine to be used for this DB cluster. Valid values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
}
variable "cluster_family" {
  type        = string
  default     = "aurora-mysql5.7"
  description = "The family of the DB cluster parameter group"
}
variable "cluster_size" {
  type        = number
  default     = 2
  description = "Number of DB instances to create in the cluster"
}
variable "engine_mode" {
  type        = string
  default     = "provisioned"
  description = "The database engine mode. Valid values: `parallelquery`, `provisioned`, `serverless`"
}

variable "engine_version" {
  type        = string
  default     = ""
  description = "The version of the database engine to use. See `aws rds describe-db-engine-versions` "
}


variable "snapshot_identifier" {
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot."
  type        = string
  default     = ""
}
variable "vpc_id" {
  description = "VPC ID to create the cluster in (e.g. `vpc-a22222ee`)"
  type        = string
}
variable "security_groups" {
  description = "List of security groups to be allowed to connect to the DB instance"
  type        = list(string)
  default     = []
}
variable "subnets" {
  type        = list(string)
  description = "List of VPC subnet IDs"
}
variable "zone_id" {
  description = "Route53 parent zone ID. If provided (not empty), the module will create sub-domain DNS records for the DB master and replicas"
  type        = string
  default     = ""
}
variable "autoscaling_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable cluster autoscaling"
}

variable "autoscaling_policy_type" {
  type        = string
  default     = "TargetTrackingScaling"
  description = "Autoscaling policy type. `TargetTrackingScaling` and `StepScaling` are supported"
}

variable "autoscaling_target_metrics" {
  type        = string
  default     = "RDSReaderAverageCPUUtilization"
  description = "The metrics type to use. If this value isn't provided the default is CPU utilization. RDSReaderAverageDatabaseConnections"
}

variable "autoscaling_target_value" {
  type        = number
  default     = 75
  description = "The target value to scale with respect to target metrics"
}
variable "autoscaling_min_capacity" {
  type        = number
  default     = 1
  description = "Minimum number of instances to be maintained by the autoscaler"
}

variable "performance_insights_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable Performance Insights"
}

variable "performance_insights_kms_key_id" {
  type        = string
  default     = ""
  description = "The ARN for the KMS key to encrypt Performance Insights data. When specifying `performance_insights_kms_key_id`, `performance_insights_enabled` needs to be set to true"
}
variable "deletion_protection" {
  type        = bool
  description = "If the DB instance should have deletion protection enabled"
  default     = false
}