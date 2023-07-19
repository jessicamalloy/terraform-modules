data "aws_iam_policy_document" "ecs-task-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Allow the ECS tasks to upload logs to CloudWatch
resource "aws_iam_policy" "ecs-task-log-policy" {
  name = "${var.project_name}-ecs-log-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [ "logs:CreateLogStream",
                     "logs:PutLogEvents",
                     "dynamodb:GetItem"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Allow the ECS Tasks to download images from ECR
resource "aws_iam_policy" "ecs-task-image-policy" {
  name = "${var.project_name}-ecs-image-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [ "ecr:GetAuthorizationToken",
                     "ecr:BatchCheckLayerAvailability",
                     "ecr:GetDownloadUrlForLayer",
                     "ecr:BatchGetImage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# This is a role which is used by the ECS tasks themselves.
resource "aws_iam_role" "ecs-task-role" {
  name                = "${var.project_name}-ecs-task-role"
  path = "/"
  assume_role_policy  = data.aws_iam_policy_document.ecs-task-assume-role-policy.json
  managed_policy_arns = concat(
    [ "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
      aws_iam_policy.ecs-task-log-policy.arn,
      aws_iam_policy.ecs-task-image-policy.arn
    ],
    var.project_managed_policy_arns
  )
}
