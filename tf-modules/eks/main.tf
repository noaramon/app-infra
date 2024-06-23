resource "aws_iam_role" "eks" {
  name = "${var.name}-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_eks_cluster" "this" {
  name     = "${var.name}"
  version  = var.eks_version
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true

    subnet_ids = var.subnet_ids
  }

  depends_on = [aws_iam_role_policy_attachment.eks]
}

resource "aws_iam_role" "nodes" {
  name = "${var.name}-nodes"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodes" {
  for_each = var.node_iam_policies

  policy_arn = each.value
  role       = aws_iam_role.nodes.name
}

resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = var.subnet_ids

  capacity_type  = each.value.capacity_type
  instance_types = each.value.instance_types

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = each.key
  }

  depends_on = [aws_iam_role_policy_attachment.nodes]
}

data "tls_certificate" "this" {
  count = var.enable_irsa ? 1 : 0

  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  count = var.enable_irsa ? 1 : 0

  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this[0].certificates[0].sha1_fingerprint]
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}


resource "aws_security_group_rule" "allow_alb_ingress" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = var.workers_sg
  source_security_group_id = var.alb_sg
}


data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
}

data "aws_eks_cluster" "main" {
  name = var.name
}

data "aws_iam_policy_document" "assume_role_with_oidc" {
  #   dynamic "statement" {
  #     # https://aws.amazon.com/blogs/security/announcing-an-update-to-iam-role-trust-policy-behavior/
  #     for_each = var.allow_self_assume_role ? [1] : []
  #
  #     content {
  #       sid     = "ExplicitSelfRoleAssumption"
  #       effect  = "Allow"
  #       actions = ["sts:AssumeRole"]
  #
  #       principals {
  #         type        = "AWS"
  #         identifiers = ["*"]
  #       }
  #
  #       condition {
  #         test     = "ArnLike"
  #         variable = "aws:PrincipalArn"
  #         values   = ["arn:${local.partition}:iam::${local.account_id}:role${var.role_path}${local.role_name_condition}"]
  #       }
  #     }
  #   }

  dynamic "statement" {
    for_each = {for k, v in var.cluster_service_accounts : k => v if var.create_role}

    content {
      effect = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type = "Federated"

        identifiers = [
          "arn:${local.partition}:iam::${local.account_id}:oidc-provider/${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
        ]
      }

      condition {
        test     = var.assume_role_condition_test
        variable = "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub"
        values = ["system:serviceaccount:${statement.value}:${statement.key}"]
      }
      condition {
        test     = var.assume_role_condition_test
        variable = "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud"
        values   = ["sts.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role" "this" {
  for_each = {for k, v in var.cluster_service_accounts : k => v if var.create_role}
  #   count = var.create_role ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.assume_role_with_oidc.json
  name               = each.key
  tags               = var.tags
}

resource "aws_iam_policy" "this" {
  for_each = {for k, v in var.cluster_service_accounts : k => v if var.create_policy}
  name     = each.key
  policy = file("${path.module}/templates/${each.key}.tpl")
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = {for k, v in var.cluster_service_accounts : k => v if var.create_role}
  role       = aws_iam_role.this[each.key].name
  policy_arn = aws_iam_policy.this[each.key].arn
}

resource "helm_release" "alb_controller" {
  name             = var.name
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version = "v1.7.1" // alb controller appVersion 2.7.0
  create_namespace = false
  namespace        = "kube-system"
  #   atomic           = true
  #   wait          = true
  #   wait_for_jobs = true
    timeout       = 120

  set {
    name  = "clusterName"
    value = var.name
  }
  set {
    name  = "serviceAccount.create"
    value = true
  }
  set {
    name  = "serviceAccount.annotations.\\eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-load-balancer-controller"
  }
  set {
    name  = "vpcId"
    value = var.vpc_id
  }
  #  set {
  #    name  = "keepTLSSecret"
  #    value = true
  #  }
  #  set {
  #    name  = "enableCertManager"
  #    value = true
  #  }

  #   values = [
  #     <<EOT
  # defaultTags:
  # %{ for key, val in local.alb_controller.tags }
  #   ${key}: ${val}
  # %{ endfor }
  # EOT
  #   ]
}
