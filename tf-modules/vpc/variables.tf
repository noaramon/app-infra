variable "cidr_block" {
  description = "CIDR (Classless Inter-Domain Routing)."
  type        = string
}

variable "name" {
  description = "Prefix for name tag"
  type        = string
}

variable "azs" {
  description = "Availability zones for subnets."
  type = list(string)
}

variable "private_subnets" {
  description = "CIDR ranges for private subnets."
  type = list(string)
}

variable "public_subnets" {
  description = "CIDR ranges for public subnets."
  type = list(string)
}

variable "tags" {
  description = "Custom tags to set on the VPC"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Private subnet tags."
  type = map(any)
}

variable "public_subnet_tags" {
  description = "Private subnet tags."
  type = map(any)
}