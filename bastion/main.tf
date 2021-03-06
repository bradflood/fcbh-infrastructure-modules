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
  version = "4.2.0"  

  vpc_id = var.vpc_id
  name   = var.security_group_name

  tags = {
    Name = var.security_group_name
  }

  ingress_cidr_blocks = var.control_cidr
  ingress_rules       = ["ssh-tcp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

locals {
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install mysql -y
EOF
}

module "host" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "2.16.0"    

  name                        = var.host_name
  vpc_security_group_ids      = [module.security_group.security_group_id]
  ami                         = data.aws_ami.linux2.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  user_data                   = local.user_data
  associate_public_ip_address = true
}
