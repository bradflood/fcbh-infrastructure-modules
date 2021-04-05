# for reference, a good article:https://chandarachea.medium.com/vpc-peering-connetion-with-terraform-c4522a24bf3e

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

data "aws_caller_identity" "current" {}

resource "aws_vpc_peering_connection" "requester_connection" {
  vpc_id        = var.requester_vpc_id
  peer_owner_id = var.accepter_owner_id
  peer_region   = var.accepter_region
  peer_vpc_id   = var.accepter_vpc_id
  auto_accept   = false
  tags = {
    Side = "Requester"
    Name = var.requester_name_tag
  }
}

data "aws_route_table" "selected" {
  subnet_id = var.requester_subnet_id
}

resource "aws_route" "requester_route" {
  route_table_id            = data.aws_route_table.selected.id
  destination_cidr_block    = var.accepter_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester_connection.id
}