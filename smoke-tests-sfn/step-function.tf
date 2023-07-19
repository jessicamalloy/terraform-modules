resource "aws_sfn_state_machine" "state_machine" {
  name     = "${var.project_name}-${local.name}"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<EOF
  {
    "Comment": "${var.step_function_description}",
    "StartAt": "SmokeTests",
    "States": {
      "SmokeTests": {
        "Type": "Parallel",
        "End": true,
        "Branches": ${jsonencode([ for i, f in var.lambda_functions : {
          "StartAt": "${f.function_name}",
          "States": {
            "${f.function_name}": {
              "Type": "Task",
              "Resource": "${aws_lambda_function.lambda_function[i].arn}",
              "End": true
            }
          }
        }])}
      }
    }
  }
  EOF

  tags = {
    ProjectName = var.project_name
  }
}

resource "aws_iam_role" "step_function_role" {
  name               = "${var.project_name}-${local.name}-role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "states.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": "StepFunctionAssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "step_function_policy" {
  name    = "${var.project_name}-${local.name}-policy"
  role    = aws_iam_role.step_function_role.id

  policy  = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Effect": "Allow",
        "Resource": "${join(",", aws_lambda_function.lambda_function[*].arn)}"
      }
    ]
  }
  EOF
}
