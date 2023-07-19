data "aws_iam_policy_document" "neo4j_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "neo4j_root" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateTags"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["elasticloadbalancing:Describe*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["autoscaling:Describe*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ec2_s3_policy" {
  statement {
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [aws_s3_bucket.backup_bucket.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.backup_bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "ec2_cloudwatch_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:CreateLogStream",
    ]
    resources = [
      "${aws_cloudwatch_log_group.neo4j_ec2_cw_agent.arn}:*",
      "${aws_cloudwatch_log_group.neo4j_nightly_backup.arn}:*",
      "${aws_cloudwatch_log_group.neo4j_ec2_setup.arn}:*",
      "${aws_cloudwatch_log_group.neo4j_db_log.arn}:*",
      "${aws_cloudwatch_log_group.neo4j_db_debug_log.arn}:*",
    ]
  }
}

resource "aws_iam_policy" "ec2_cloudwatch_policy" {
  name   = "${var.project_name}-ec2-cloudwatch-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ec2_cloudwatch_policy.json
}

resource "aws_iam_policy" "ec2_s3_policy" {
  name   = "${var.project_name}-ec2-s3-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ec2_s3_policy.json
}

resource "aws_iam_role" "neo4j_assumable_role" {
  name               = "WorkWithTags-Neo4j${title(var.neo4j_edition)}-${title(var.project_name)}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.neo4j_role_policy.json
}

resource "aws_iam_instance_profile" "neo4j_instance_profile" {
  name = "ReadOwnTags-Neo4j${title(var.neo4j_edition)}-${title(var.project_name)}"
  path = "/"
  role = aws_iam_role.neo4j_assumable_role.name
}

resource "aws_iam_role_policy" "neo4j_assumable_role_policy" {
  name   = "root"
  role   = aws_iam_role.neo4j_assumable_role.id
  policy = data.aws_iam_policy_document.neo4j_root.json
}

resource "aws_iam_role_policy_attachment" "ec2_s3_policy" {
  role       = aws_iam_role.neo4j_assumable_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_policy" {
  role       = aws_iam_role.neo4j_assumable_role.name
  policy_arn = aws_iam_policy.ec2_cloudwatch_policy.arn
}
