data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        var.oidc_provider_arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:sub"

      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account_name}"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "app" {
  name = "${var.project_name}-${var.environment}-app-irsa-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "app" {
  statement {
    sid    = "ListRawBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      var.bucket_arn
    ]
  }

  statement {
    sid    = "RawBucketObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${var.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "UseDataKmsKey"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]

    resources = [
      var.kms_key_arn
    ]
  }
}

resource "aws_iam_policy" "app" {
  name   = "${var.project_name}-${var.environment}-app-policy"
  policy = data.aws_iam_policy_document.app.json
}

resource "aws_iam_role_policy_attachment" "app" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app.arn
}