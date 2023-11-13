resource "aws_s3_bucket" "lambdas_bucket" {
  bucket        = "${var.project_name}-${local.name}-lambdas-bucket"
  force_destroy = true

  tags = {
    ProjectName = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "lambdas_bucket_restrict_public_access" {
  bucket = aws_s3_bucket.lambdas_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "archive_file" "dummy_lambda" {
  type        = "zip"
  output_path = var.s3_key

  source {
    content  = "fake"
    filename = "fake-lambda.txt"
  }
}

resource "aws_s3_bucket_object" "file_upload" {
  bucket = aws_s3_bucket.lambdas_bucket.id
  key    = var.s3_key
  source = data.archive_file.dummy_lambda.output_path
}

resource "aws_lambda_function" "lambda_function" {
  count = length(var.lambda_functions)

  function_name = "${var.project_name}-${var.lambda_functions[count.index].function_name}"
  description   = var.lambda_functions[count.index].description

  s3_bucket = aws_s3_bucket.lambdas_bucket.id
  s3_key    = var.s3_key

  role        = aws_iam_role.lambda_role.arn
  handler     = var.lambda_functions[count.index].handler
  runtime     = var.lambda_functions[count.index].runtime
  memory_size = var.lambda_functions[count.index].memory_size
  timeout     = var.lambda_functions[count.index].timeout

  environment {
    variables = merge({"SERVICE_URL": var.service_url}, var.lambda_functions[count.index].env_vars)
  }

  tags = {
    ProjectName = var.project_name
  }

  depends_on = [
    aws_iam_policy_attachment.lambda_log_policy,
    aws_cloudwatch_log_group.log_group,
    aws_s3_bucket_object.file_upload,
  ]
}

resource "aws_cloudwatch_log_group" "log_group" {
  count = length(var.lambda_functions)

  name              = "/aws/lambda/${local.name}/${var.lambda_functions[count.index].function_name}"
  retention_in_days = 14

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect    = "Allow"
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      format(
        "arn:aws:logs:%s:%s:*",
        var.region,
        var.aws_account_id
      )
    ]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project_name}-${local.name}-lambda-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_role_policy.json
}

resource "aws_iam_policy" "lambda_log_policy" {
  name   = "${var.project_name}-${local.name}-lambda-log-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_policy_attachment" "lambda_log_policy" {
  name       = "${var.project_name}-${local.name}-lambda-log-policy-attach"
  roles      = [
    aws_iam_role.lambda_role.id
  ]
  policy_arn = aws_iam_policy.lambda_log_policy.arn
}
