# tf-modules/ecr/variables.tf

variable "name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Can be one of: MUTABLE, IMMUTABLE"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Custom tags to set on the ECR"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region"
  default = "us-east-1"
}