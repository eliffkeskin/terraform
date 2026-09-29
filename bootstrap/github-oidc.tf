resource "aws_iam_openid_connect_provider" "default" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]
}

data "aws_iam_policy_document" "default_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity", "sts:TagSession"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.default.arn]
    }
    condition {
      test = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = ["repo:eliffkeskin@76158485/terraform@1371463043:*"]

    }
  }
}

resource "aws_iam_role" "default_role" {
  name = "default_role"
  path = "/system/"
  assume_role_policy = data.aws_iam_policy_document.default_role_policy.json
}

resource "aws_iam_role_policy_attachment" "admin_access_role_attachment" {
  role = aws_iam_role.default_role.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
