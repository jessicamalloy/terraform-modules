module "code_build" {
  source                = "github.com/jessicamalloy/terraform-modules/ecs-codebuild"
  project_name          = var.project_name
  aws_account_id        = var.aws_account_id
  region                = var.region
  buildspec             = var.buildspec
  github_username       = var.github_username
  github_access_token   = var.github_access_token
  docker_secret_id      = module.secrets_manager.secret_id
  build_env_image       = var.build_env_image
  build_timeout         = var.build_timeout
  environment_variables = var.environment_variables
  s3_bucket_resources   = var.s3_bucket_resources
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = module.code_build.project_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_oauth_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = var.project_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName : "${var.ecs_cluster}"
        ServiceName : "${var.ecs_service}"
      }
    }
  }

  dynamic "stage" {
    for_each = var.pipeline_stages
    content {
      name = stage.value.name
      action {
        name          = stage.value.action_name
        category      = stage.value.action_category
        owner         = stage.value.action_owner
        provider      = stage.value.action_provider
        version       = stage.value.action_version
        configuration = stage.value.configuration
      }
    }
  }

  tags = {
    name        = "${var.project_name}-pipeline"
    ProjectName = var.project_name
  }
}
