terraform {
  source = "git::git@github.com:noaramon/app-infra.git//tf-modules/ecr?ref=aws-ecr-0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  tags = {
    Application = "ECR"
  }
  default_tags = read_terragrunt_config(find_in_parent_folders())
}

inputs = {
  name                 = "example-ecr-repo"
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  tags = merge(local.default_tags.locals.default_tags, local.tags)
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
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
