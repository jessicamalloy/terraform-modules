# ECS Code Pipeline

This module creates a Codepipeline to build and deploy a platform ECS service.

## Examples

This example assumes a platform ECS service has been created for "foo" project using modules, vpc, and ecs.  This is only an example and is assumed that sensitive variables like tokens would not be stored directly in the module definition.

```terraform
module "dats_codepipeline" {
  source = "github.com/AllenInstitute/platform-terraform-modules/ecs-codepipeline-core" 
  project_name          = var.project_name
  aws_account_id        = var.aws_account_id
  region                = var.region
  ecs_cluster           = module.foo_ecs.ecs_cluster
  ecs_service           = module.foo_ecs.ecs_service
  github_oauth_token    = "githubOAuthToken"
  github_repo           = "FooRepo"
  github_branch         = "main"
  github_username       = var.github_username
  github_access_token   = var.github_access_token
  docker_username       = "dockerUsername"
  docker_login_token    = "dockerLoginToken"
  buildspec             = file("./buildspec.yml")
}
```

This example assumes it's being used for a platform services project using modules, vpc, and ecs.  This is only an example and is assumed that sensitive variables like tokens would not be stored directly in the module definition.

```terraform
module "dats_codepipeline" {
  source = "github.com/AllenInstitute/platform-terraform-modules/ecs-codepipeline-core" 
  project_name          = var.project_name
  aws_account_id        = var.aws_account_id
  region                = var.region
  ecs_cluster           = module.foo_ecs.ecs_cluster
  ecs_service           = module.foo_ecs.ecs_service
  github_oauth_token    = "githubOAuthToken"
  github_repo           = "FooRepo"
  github_branch         = "main"
  github_username       = var.github_username
  github_access_token   = var.github_access_token
  docker_username       = "dockerUsername"
  docker_login_token    = "dockerLoginToken"
  buildspec             = file("./buildspec.yml")
  environment_variables = [
    {
      name  = "PROJECT_DIRECTORY"
      value = var.project_directory
      type  = "PLAINTEXT"
    },
    {
      name  = "ECS_CONTAINER"
      value = module.dats_ecs.ecs_container
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_NAME"
      value = "${var.db_secret}:dbname"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "DB_HOST"
      value = "${var.db_secret}:host"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "DB_PORT"
      value = "${var.db_secret}:port"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "DB_USER"
      value = "${var.db_secret}:username"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "DB_PASSWORD"
      value = "${var.db_secret}:password"
      type  = "SECRETS_MANAGER"
    }
  ]
}
```

This example is similar to the example above, except it includes a validation stage to run smoke tests. Also uses the smoke_test_sfn module.

```terraform
module "dats_codepipeline" {
  source = "github.com/AllenInstitute/platform-terraform-modules/ecs-codepipeline-core" 
  project_name          = var.project_name
  aws_account_id        = var.aws_account_id
  region                = var.region
  ecs_cluster           = module.dats_ecs.ecs_cluster
  ecs_service           = module.dats_ecs.ecs_service
  github_oauth_token    = "githubOAuthToken"
  github_repo           = "DigitalAssetTracking"
  github_branch         = "main"
  github_username       = var.github_username
  github_access_token   = var.github_access_token
  docker_username       = "dockerUsername"
  docker_login_token    = "dockerLoginToken"
  buildspec             = file("./buildspec.yml")
  environment_variables = [
    {
      name  = "PROJECT_DIRECTORY"
      value = var.project_directory
      type  = "PLAINTEXT"
    },
    {
      name  = "ECS_CONTAINER"
      value = module.dats_ecs.ecs_container
      type  = "PLAINTEXT"
    },
    {
      name  = "DB_NAME"
      value = "${var.db_secret}:dbname"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "DB_HOST"
      value = "${var.db_secret}:host"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "DB_PORT"
      value = "${var.db_secret}:port"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "DB_USER"
      value = "${var.db_secret}:username"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "DB_PASSWORD"
      value = "${var.db_secret}:password"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "DigitalAssetTrackingSmokeTests"
      value = "${var.verification_project_directory}"
      type = "PLAINTEXT"
    },
    {
      name = "VERIFICATION_LAMBDAS"
      value = join(",", module.smoke_test_sfn.function_names)
      type = "PLAINTEXT"
    },
    {
      name  = "VERIFICATION_LAMBDA_BUCKET"
      value = "${var.verification_lambda_bucket}"
      type = "PLAINTEXT"
    },
    {
      name  = "VERIFICATION_LAMBDA_S3_KEY"
      value = "SmokeTests.zip"
      type = "PLAINTEXT"
    }
  ]
  pipeline_stages = var.verification_stage ? [
    {
      name = "Verify"
      action_name     = "Verify"
      action_category = "Invoke"
      action_owner    = "AWS"
      action_provider = "StepFunctions"
      action_version  = "1"
      configuration = {
        StateMachineArn: module.smoke_test_sfn.arn
      }
    }
  ] : []
  s3_bucket_resources = var.verification_stage ? [
    module.smoke_test_sfn.lambda_bucket_arn,
    format("%s/*", module.smoke_test_sfn.lambda_bucket_arn)
  ] : []
}
```

## Variables

| name | type                                                 | default | description |
| --- |------------------------------------------------------| --- | --- |
| project_name | string                                               | `N/A` | (Mandatory) Name of project used for naming all resources. Maximum 41 characters. |
| github_oauth_token | string                                               | `N/A` | (Mandatory) OAuth token allowing access to repository. |
| github_owner | string                                               | `AllenInstitute` | (Optional) GitHub repo owner. |
| github_username | string                                               | `aibsgithub` | (Optional) GitHub service account username. |
| github_access_token | string                                               | `N/A` | GitHub personal access token for nuget package access. |
| github_branch | string                                               | `N/A` | (Mandatory) GitHub git branch. |
| github_repo | string                                               | `N/A` | (Mandatory) GitHub git repo. |
| aws_account_id | string                                               | `N/A` | (Mandatory) AWS account id where ecs service is deployed. |
| docker_username | string                                               | `N/A` | (Mandatory) User name for Docker account used during build. |
| docker_login_token | string                                               | `N/A` | (Mandatory) Docker login token for Docker account used during build. |
| ecs_service | string                                               | `N/A` | (Mandatory) Name of ECS Service. |
| ecs_cluster | string                                               | `N/A` | (Mandatory) Name of ECS Cluster. |
| ecs_container | string                                               | `N/A` | (Mandatory) Name of ECS Container. |
| build_timeout | number                                               | `10` | (Optional) Timeout for build in minutes. |
| buildspec | string                                               | `N/A` | (Mandatory) File contents of the buildspec. |
| build_env_image | string                                               | `aws/codebuild/standard:7.0` | (Optional) Docker image to use for this build project. |
| environment_variables | list(object({name=string,value=string,type=string})) | `[]` | (Optional) List of additional environment variables to pass to build. |
| region | string                                               | `N/A` | (Mandatory) AWS region where secret will be stored. |
| pipeline_stages | list                                                 | `[]]` | (Optional) Addition pipeline stages to be added to CodePipeline. |
| s3_bucket_resources | list                                                 | `[]` | (Optional) Additional s3 bucket resources (arn) that CodePipeline will need permission for. This is required if any additional pipeline
stages use other s3 buckets. |
