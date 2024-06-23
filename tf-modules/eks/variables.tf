variable "eks_version" {
  description = "Desired Kubernetes master version."
  type        = string
}

variable "name" {
  description = "Name of the cluster. Used as a prefix"
  type        = string
}

variable "vpc_id" {
  description = "ID of the desired vpc"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs. Must be in at least two different availability zones."
  type        = list(string)
}

variable "node_iam_policies" {
  description = "List of IAM Policies to attach to EKS-managed nodes."
  type        = map(any)
  default = {
    1 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    2 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    3 = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    4 = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

variable "node_groups" {
  description = "EKS node groups"
  type        = map(any)
}

variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Custom tags to set on the EKS"
  type        = map(string)
  default     = {}
}

variable "alb_sg" {
  description = "ID of the ALB security group"
}

variable "workers_sg" {
  description = "ID of the EKS workers"
}

variable "cluster_service_accounts" {
  description = "EKS cluster and k8s ServiceAccount pairs. Each EKS cluster can have multiple k8s ServiceAccount. See README for details"
  type        = map(string)
  default     = {}
}

variable "create_role" {
  description = "Whether to create a role"
  type        = bool
  default     = true
}


variable "assume_role_condition_test" {
  description = "Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role"
  type        = string
  default     = "StringEquals"
}

variable "create_policy" {
  description = "Whether to create the IAM policy"
  type        = bool
  default     = true
}

