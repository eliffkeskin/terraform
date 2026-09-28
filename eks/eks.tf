resource "aws_eks_cluster" "test_cluster" {
  name     = "test_cluster"
  version  = "1.35"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids = module.network.private_subnet_ids
  }

  access_config {
    authentication_mode = "API"
  }

  bootstrap_self_managed_addons = false

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose"]
    node_role_arn = aws_iam_role.node_role.arn
  }
  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_role_policy_attachment,
    aws_iam_role_policy_attachment.node_role_policy_attachment
  ]
}


resource "aws_eks_access_entry" "test" {
  cluster_name  = aws_eks_cluster.test_cluster.name
  principal_arn = var.admin_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "test" {
  cluster_name  = aws_eks_cluster.test_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.admin_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.test]
}
