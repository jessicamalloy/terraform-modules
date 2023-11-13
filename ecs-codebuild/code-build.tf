resource "aws_s3_bucket" "project_bucket" {
  bucket        = "${var.project_name}-artifact-bucket"
  force_destroy = true

  tags = {
    ProjectName = var.project_name
  }
}

resource "aws_ecr_repository" "ecr_repo" {
  name = var.project_name

  tags = {
    name        = "${var.project_name}"
    ProjectName = var.project_name
  }
}

resource "aws_codebuild_project" "project_codebuild" {
  name          = var.project_name
  description   = "Codebuild for project: ${var.project_name}"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.codebuild_service_role.arn

  dynamic "vpc_config" {
    // trick to conditionally set this argument
    for_each = var.vpc_config == null ? [] : [1]

    content {
      security_group_ids = var.vpc_config["security_group_ids"]
      subnets            = var.vpc_config["subnets"]
      vpc_id             = var.vpc_config["vpc_id"]
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = var.build_env_image
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "REPOSITORY_URI"
      value = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.project_name}"
    }

    environment_variable {
      name  = "BUILD_ARTIFACT_BUCKET"
      value = aws_s3_bucket.project_bucket.bucket
    }

    environment_variable {
      name  = "GITHUB_USERNAME"
      value = var.github_username
    }

    environment_variable {
      name  = "GITHUB_ACCESS_TOKEN"
      value = var.github_access_token
    }

    environment_variable {
      name  = "DOCKER_USERNAME"
      value = "${var.docker_secret_id}:username"
      type  = "SECRETS_MANAGER"
    }

    environment_variable {
      name  = "DOCKER_LOGIN_TOKEN"
      value = "${var.docker_secret_id}:loginToken"
      type  = "SECRETS_MANAGER"
    }

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
        type  = environment_variable.value["type"]
      }
    }
  }

  tags = {
    name        = "${var.project_name}"
    ProjectName = var.project_name
  }
}
