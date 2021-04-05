# AWS 
variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_profile" {
  type    = string
}
variable "vpc_id" {
  type    = string
}
variable "splunk_subnet_id" {
  type    = string
}
variable "route53_zone_id" {
  type    = string
  description = "Zone id for route53"
}
variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones"
}
variable "elb_subnets" {
  type        = list(string)
  description = "List of Subnets"
}
variable "domain_name" {
  description = "Provide the TLD for your test Splunk Instance ex. \"example.com\""
}
variable "certificate_arn" {
  description = "Provide the ARN for the certificate used for the LB"
}
variable "ssh_pub_key_name" {
  description = "Provide name of existing ssh public key"
}

variable "bastion_security_group_id" {
  description = "ID of Bastion Security Group"
}
variable "elb_access_cidr" {
  description = "Provide an array of CIDR blocks which can access the Splunk web interface"
  type = list(string)
}

variable "splunk_ami" {
  description = "Provide the AWS AMI id to be loaded in each Splunk EC2 instance "
}
variable "prod_search_head_instance_type" {
  description="instance type for production search head"
}
# variable "indexer_instance_type" {
#   description="instance type for indexer"
# }
variable "forwarder_instance_type" {
  description="instance type for forwarder"
}
variable "forwarder_iam_instance_profile" {
  description="instance profile for forwarder"
  default = ""
}
variable "splunk_license_server_cidr" {
  description = "CIDR blocks for Splunk license server, egress from splunk security group"
  type = list(string)
}
variable "peer_cidr_blocks" {
  description = "CIDR blocks which can access SQL port on splunk security group"
  type = list(string)
}
