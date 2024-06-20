remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "tf.test.state"
    key            = "${path_relative_to_include("root")}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf.lock-table"
  }
}

locals {
  default_tags = {
    Department   = "devops"
    Team         = "noa"
    Environment  = "prod"
    CostCenter   = "example"
    BusinessUnit = "example"
    WorkloadType = "compute"
    Terraform    = "Yes"
  }
}