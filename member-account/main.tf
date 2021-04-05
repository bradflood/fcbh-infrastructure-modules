
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }  
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  required_version = ">= 0.13"
}

# 1. create organization member account
# setting iam_user_access_to_billing = "ALLOW" will enable IAM users in the new account to view account billing information if they have the required permissions. 
# This can be useful if subaccount is contracted out, and the contractor is accountable for maintaining a budget
# https://www.terraform.io/docs/providers/aws/r/organizations_account.html
resource "aws_organizations_account" "account" {
  name                       = var.member_account_name
  email                      = var.member_account_email
  parent_id                  = var.parent_id
  role_name                  = "AdminRoleFromOrg"
  iam_user_access_to_billing = "ALLOW"

  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name]
  }
}

#TODO: refer to cloudposse repo when https://github.com/cloudposse/terraform-aws-organization-access-group/pull/16 is merged
module "organization_access_group" {
  source      = "git::https://github.com/techfishio/terraform-aws-organization-access-group.git?ref=tags/0.6.0"
  namespace   = var.namespace
  stage       = var.stage
  name        = var.name
  user_names  = var.iam_users_accessing_member_account
  # role_arns   = map("key", format("arn:aws:iam::%d:role/OrganizationAccountAccessRole", aws_organizations_account.account.id))
  role_arns = [format("arn:aws:iam::%d:role/OrganizationAccountAccessRole", aws_organizations_account.account.id)]
  require_mfa = "false"
}

# Note:
# If the organization invites an existing account, one bit of configuration is needed in the invited account, that
# is done automatically when an account is created as part of an Organization. 
# The role OrganizationAccountAccessRole needs to be created.
# module "organization_access_role" {
#   source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-role.git?ref=master"
#   master_account_id = var.organization_master_account_id
#   role_name         = "OrganizationAccountAccessRole"
#   policy_arn        = "arn:aws:iam::aws:policy/AdministratorAccess"
# }
