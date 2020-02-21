provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  # The latest version of Terragrunt (v0.19.0 and above) requires Terraform 0.12.0 or above.
  required_version = ">= 0.12.0"
}

data "aws_ami" "linux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20190313-x86_64-gp2"]
  }


  owners = ["137112412989"] # AWS
}

module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  vpc_id = var.vpc_id
  name   = var.security_group_name

  tags = {
    Name = var.security_group_name
  }

  ingress_cidr_blocks = var.control_cidr #["0.0.0.0/0"] #[var.control_cidr]
  ingress_rules       = ["ssh-tcp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

locals {
  user_data = <<EOF
#!/bin/bash
echo 'Woot!' > /home/ec2-user/user-script-output.txt
yum update -y
yum install mysql -y
EOF
}

module "host" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = var.host_name
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  ami                         = data.aws_ami.linux2.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  user_data                   = local.user_data
  associate_public_ip_address = true
}

# TODO
# get a linux2 instance that doesn't need a yum update

