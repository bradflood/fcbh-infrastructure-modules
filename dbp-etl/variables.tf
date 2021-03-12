variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ecs_subnets" {
  type = list(string)
}

variable "ecs_security_group" {
  type = string
}

variable "database_user" {
  type    = string
  default = "sa"
}

variable "database_passwd" {
  type = string
}

variable "database_user_db_name" {
  type    = string
  default = "dbp_users"
}

variable "database_host" {
  type = string
}

variable "database_port" {
  type    = string
  default = "3306"
}

variable "database_db_name" {
  type    = string
  default = "dbp_NEWDATA"
}

variable "s3_bucket" {
  type    = string
  default = "dbp-prod"
}

variable "s3_vid_bucket" {
  type    = string
  default = "dbp-vid"
}

variable "s3_artifacts_bucket" {
  type    = string
  default = "dbp-etl-artifacts"
}

variable "acm_certificate_arn" {
  type    = string
  default = null
}

variable "alias" {
  type    = string
  default = null
}

variable "dbs_aws_access_key_id" {
  type    = string
  default = null
}

variable "dbs_aws_secret_access_key" {
  type    = string
  default = null
}
