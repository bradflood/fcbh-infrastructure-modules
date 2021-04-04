variable "aws_region" {
}

variable "aws_profile" {
  type    = string
}
###################################

variable "host_name" {
  default = "Bastion Host"
}
variable "instance_type" {
  default = "t3.nano"
}
variable "vpc_id" {
}
variable "subnet_id" {
}
variable "key_name" {
}

variable "security_group_name" {
  default = "Bastion Security Group"
}

variable "control_cidr" {
  type = list(string)
}







