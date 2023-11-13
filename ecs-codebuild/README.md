# ECS Code Build

This module creates a CodeBuild build and deploy a platform ECS service. This is intended to be used with our ecs-codepipeline module.

## Examples

This example assumes a platform ECS service has been created for a project using modules vpc, and ecs. This is only an example and is assumed that sensitive variables like tokens would not be stored directly in the module definition.

```terraform
module "codebuild" {
  project_name          = var.project_name
  aws_account_id        = var.aws_account_id
  region                = var.region
  buildspec             = file(var.buildspec)
  github_username       = var.github_username
  github_access_token   = var.github_access_token
  docker_secret_id      = module.secrets_manager.secret_id
  build_env_image       = var.build_env_image
  build_timeout         = var.build_timeout
  environment_variables = var.environment_variables
  s3_bucket_resources   = var.s3_bucket_resources
}
```

## Variables

| name | type                                                 | default | description |
| --- |------------------------------------------------------| --- | --- |
| project_name | string                                               | `N/A` | (Mandatory) Name of project used for naming all resources. Maximum 41 characters. |
| github_username | string                                               | `aibsgithub` | (Optional) GitHub service account username. |
| github_access_token | string                                               | `N/A` | GitHub personal access token for nuget package access. |
| aws_account_id | string                                               | `N/A` | (Mandatory) AWS account id where ecs service is deployed. |
| docker_secret_id | string                                               | `N/A` | (Mandatory) The secret id of where docker credentials are stored. |
| build_timeout | number                                               | `10` | (Optional) Timeout for build in minutes. |
| buildspec | string                                               | `N/A` | (Mandatory) File contents of the buildspec. |
| build_env_image | string                                               | `aws/codebuild/standard:7.0` | (Optional) Docker image to use for this build project. |
| environment_variables | list(object({name=string,value=string,type=string})) | `[]` | (Optional) List of additional environment variables to pass to build. |
| region | string                                               | `N/A` | (Mandatory) AWS region where secret will be stored. |
