terraform {
  source = "git::git@github.com:noaramon/app-infra.git//tf-modules/vpc?ref=aws-vpc-0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  tags = {
    Application = "VPC"
  }
  default_tags = read_terragrunt_config(find_in_parent_folders())
}

inputs = {
  name       = "example-vpc"
  cidr_block = "10.0.0.0/16"
  azs = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnets = ["10.0.64.0/19", "10.0.96.0/19"]
  tags = merge(local.default_tags.locals.default_tags, local.tags)
  private_subnet_tags = {
    "type" = "private",
    "kubernetes.io/role/internal-elb" = 1
  }

  public_subnet_tags = {
    "type" = "public"
    "kubernetes.io/role/elb" = 1
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.54"
    }
  }
}
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = var.tags
  }
}
EOF
}
