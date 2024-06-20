terraform {
  source = "git::git@github.com:noaramon/app-infra.git//tf-modules/eks?ref=aws-eks-0.0.2"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  tags = {
    Application = "EKS"
  }
  default_tags = read_terragrunt_config(find_in_parent_folders())
}


dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    private_subnet_ids = ["subnet-1234", "subnet-5678"]
  }
}

inputs = {
  name        = "example-eks"
  eks_version = "1.30"
  subnet_ids  = dependency.vpc.outputs.private_subnet_ids
  vpc_id      = dependency.vpc.outputs.vpc_id

  node_groups = {
    general = {
      capacity_type = "SPOT"
      instance_types = ["t3.large"]
      scaling_config = {
        desired_size = 1
        max_size     = 1
        min_size     = 0
      }
    }
  }
  tags = merge(local.default_tags.locals.default_tags, local.tags)
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
