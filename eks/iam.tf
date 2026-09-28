data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "node_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster_role" {
  name               = "cluster_role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.json

}

resource "aws_iam_role" "node_role" {
  name               = "node_role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role_policy.json

}

resource "aws_iam_role_policy_attachment" "cluster_role_policy_attachment" {
  for_each   = toset(["AmazonEKSClusterPolicy", "AmazonEKSComputePolicy", "AmazonEKSBlockStoragePolicy", "AmazonEKSLoadBalancingPolicy", "AmazonEKSNetworkingPolicy"])
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

resource "aws_iam_role_policy_attachment" "node_role_policy_attachment" {
  for_each   = toset(["AmazonEKSWorkerNodeMinimalPolicy", "AmazonEC2ContainerRegistryPullOnly"])
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}