data "template_file" "buildspec" {
  template = var.verification_stage ? file(local.buildspec_verification) : file(local.buildspec)
  vars = {
    extra_install_steps = length(var.extra_buildspec_install_steps) > 0 ? indent(6, chomp(yamlencode(var.extra_buildspec_install_steps))) : ""
  }
}

module "codepipeline" {
  source              = "..//ecs-codepipeline-core"
  project_name        = var.project_name
  aws_account_id      = var.aws_account_id
  region              = var.region
  ecs_cluster         = var.ecs_cluster
  ecs_service         = var.ecs_service
  github_owner        = var.github_owner
  github_oauth_token  = var.github_oauth_token
  github_repo         = var.github_repo
  github_branch       = var.github_branch
  github_access_token = var.github_access_token
  github_username     = var.github_username
  docker_username     = var.docker_username
  docker_login_token  = var.docker_login_token
  build_timeout       = var.build_timeout
  buildspec           = data.template_file.buildspec.rendered
  build_env_image     = var.build_env_image
  environment_variables = concat([
    {
      name  = "PROJECT_DIRECTORY"
      value = var.project_directory
      type  = "PLAINTEXT"
    },
    {
      name  = "ECS_CONTAINER"
      value = var.ecs_container
      type  = "PLAINTEXT"
    },
    {
      name  = var.data_store_type == "rds" ? "DB_NAME" : "NEO4J_DB_NAME"
      value = "${var.db_secret}:dbname"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = var.data_store_type == "rds" ? "DB_HOST" : "NEO4J_HOST"
      value = "${var.db_secret}:host"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = var.data_store_type == "rds" ? "DB_PORT" : "NEO4J_PORT"
      value = "${var.db_secret}:port"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = var.data_store_type == "rds" ? "DB_USER" : "NEO4J_USERNAME"
      value = "${var.db_secret}:username"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = var.data_store_type == "rds" ? "DB_PASSWORD" : "NEO4J_PASSWORD"
      value = "${var.db_secret}:password"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "VERIFICATION_PROJECT_DIRECTORY"
      value = "${var.verification_project_directory}"
      type  = "PLAINTEXT"
    },
    {
      name  = "VERIFICATION_LAMBDAS"
      value = "${var.verification_lambda_function_names}"
      type  = "PLAINTEXT"
    },
    {
      name  = "VERIFICATION_LAMBDA_BUCKET"
      value = "${var.verification_lambda_bucket}"
      type  = "PLAINTEXT"
    },
    {
      name  = "VERIFICATION_LAMBDA_S3_KEY"
      value = "${var.verification_lambda_s3_key}"
      type  = "PLAINTEXT"
    }
    ],
    var.environment_variables
  )
  pipeline_stages = var.verification_stage ? [
    {
      name            = "Verify"
      action_name     = "Verify"
      action_category = "Invoke"
      action_owner    = "AWS"
      action_provider = "StepFunctions"
      action_version  = "1"
      configuration = {
        StateMachineArn : var.verification_state_machine_arn
      }
    }
  ] : []
  s3_bucket_resources = var.verification_stage ? [
    var.verification_lambda_bucket_arn,
    format("%s/*", var.verification_lambda_bucket_arn)
  ] : []
}
