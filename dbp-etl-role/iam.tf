resource "aws_iam_role" "iam" {
  name               = "dbp-etl-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.iam_assume.json
}

data "aws_iam_policy_document" "iam_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::078432969830:root"]
    }
  }
}

resource "aws_iam_policy" "iam" {
  name   = "dbp-etl-${var.environment}"
  policy = data.aws_iam_policy_document.iam.json
}

data "aws_iam_policy_document" "iam" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [for x in var.s3_buckets : "arn:aws:s3:::${x}"]
  }

  statement {
    actions   = ["s3:*Object*"]
    resources = [for x in var.s3_buckets : "arn:aws:s3:::${x}/*"]
  }

  statement {
    actions   = ["elastictranscoder:*"]
    resources = var.elastictranscoder_arns
  }

  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = var.lambda_function_arns
  }
}

resource "aws_iam_role_policy_attachment" "iam" {
  role       = aws_iam_role.iam.name
  policy_arn = aws_iam_policy.iam.arn
}
