# ECS Code Pipeline

This module creates a Codepipeline to build and deploy a platform ECS service.

## VPC Considerations

The `vpc_config` list(object) variable can be used to place the codepipeline 
build projects within a VPC. This is often needed to manage resources that are
placed in the same VPC (such as RDS databases). As a best practice, it's
recommended to place the pipeline inside of a private subnet. The majority of
the time, the provided security group can deny all ingress but must allow
egress for the required endpoints.

See example in next section below.

## Examples

This example assumes a platform ECS service has been created for the "dats" project using modules, vpc, ecs, and rds.  This is only an example and is assumed that sensitive variables like tokens would not be stored directly in the module definition.

```terraform
module "dats_codepipeline" {
  source = "github.com/AllenInstitute/platform-terraform-modules/ecs-codepipeline"
  project_name       = var.project_name
  aws_account_id     = var.aws_account_id
  region             = var.region
  ecs_cluster        = module.dats_ecs.ecs_cluster
  ecs_service        = module.dats_ecs.ecs_service
  ecs_container      = module.dats_ecs.ecs_container
  github_repo        = "DigitalAssetTracking"
  github_branch      = "main"
  codestar_connection_arn  = "codestar_connection_arn"
  docker_username    = "dockerUsername"
  docker_login_token = "dockerLoginToken"
  db_secret          = module.dats_db.db_secret_id
  project_directory  = "DigitalAssetTracking"
}
```

This example is similar to the example above, except it includes a validation stage to run smoke tests. Also uses the smoke_test_sfn module.

```terraform
module "dats_codepipeline" {
  source = "github.com/AllenInstitute/platform-terraform-modules/ecs-codepipeline"
  project_name       = var.project_name
  aws_account_id     = var.aws_account_id
  region             = var.region
  ecs_cluster        = module.dats_ecs.ecs_cluster
  ecs_service        = module.dats_ecs.ecs_service
  ecs_container      = module.dats_ecs.ecs_container
  codestar_connection_arn  = "codestar_connection_arn"
  github_repo        = "DigitalAssetTracking"
  github_branch      = "main"
  docker_username    = "dockerUsername"
  docker_login_token = "dockerLoginToken"
  db_secret          = module.dats_db.db_secret_id
  project_directory  = "DigitalAssetTracking"

  verification_stage                 = true
  verification_project_directory     = "DigitalAssetTrackingSmokeTests"
  verification_state_machine_arn     = module.smoke_test_sfn.arn
  verification_lambda_function_names = join(",", module.smoke_test_sfn.function_names)
  verification_lambda_bucket         = module.smoke_test_sfn.lambda_bucket
  verification_lambda_bucket_arn     = module.smoke_test_sfn.lambda_bucket_arn
  verification_lambda_s3_key         = "SmokeTests.zip"
}
```

## Using `extra_buildspec_install_steps`

```terraform
module "sfs_codepipeline" {
  source = "github.com/AllenInstitute/platform-terraform-modules/ecs-codepipeline"
  project_name       = var.project_name
  aws_account_id     = var.aws_account_id
  region             = var.region
  ecs_cluster        = module.sfs_ecs.ecs_cluster
  ecs_service        = module.sfs_ecs.ecs_service
  ecs_container      = module.sfs_ecs.ecs_container
  github_repo        = "SpecimenFeatureStore"
  github_branch      = "main"
  codestar_connection_arn  = "codestar_connection_arn"
  docker_username    = "dockerUsername"
  docker_login_token = "dockerLoginToken"
  db_secret          = module.sfs_db.db_secret_id
  project_directory  = "SpecimenFeatureStore"

  extra_buildspec_install_steps = [
    "curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel STS"
  ]

  verification_stage                 = true
  verification_project_directory     = "SpecimenFeatureStoreSmokeTests"
  verification_state_machine_arn     = module.smoke_test_sfn.arn
  verification_lambda_function_names = join(",", module.smoke_test_sfn.function_names)
  verification_lambda_bucket         = module.smoke_test_sfn.lambda_bucket
  verification_lambda_bucket_arn     = module.smoke_test_sfn.lambda_bucket_arn
  verification_lambda_s3_key         = "SmokeTests.zip"
}
```

This example places the pipeline inside of a VPC. It creates a security group
that is used for the build projects.

```terraform
module "vpc" {
  source                 = "github.com/AllenInstitute/platform-terraform-modules/vpc"
  project_name           = var.project_name
  create_private_subnets = true
  number_of_azs          = 3
}

resource "aws_security_group" "pipeline" {
  name   = "pipeline-sg"
  vpc_id = module.vpc.id

  // this example allows all egress, but it can be further limited to just what
  // the pipeline needs
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // note there is no ingress - all ingress is denied be default
}

module "dats_codepipeline" {
  source = "github.com/AllenInstitute/platform-terraform-modules/ecs-codepipeline"
  project_name       = var.project_name
  aws_account_id     = var.aws_account_id
  region             = var.region
  ecs_cluster        = module.dats_ecs.ecs_cluster
  ecs_service        = module.dats_ecs.ecs_service
  ecs_container      = module.dats_ecs.ecs_container
  github_repo        = "DigitalAssetTracking"
  github_branch      = "main"
  codestar_connection_arn  = "codestar_connection_arn"
  docker_username    = "dockerUsername"
  docker_login_token = "dockerLoginToken"
  db_secret          = module.dats_db.db_secret_id
  project_directory  = "DigitalAssetTracking"

  vpc_config = {
    security_group_ids = [aws_security_group.pipeline.id]
    subnets            = module.vpc.private_subnets
    vpc_id             = module.vpc.id
  }
}
```

## Variables
| name | type | default | description |
| --- | --- | --- | --- |
| project_name | string | `N/A` | (Mandatory) Name of project used for naming all resources. Maximum 41 characters. |
| github_owner | string | `AllenInstitute` | (Optional) GitHub repo owner. |
| github_username | string | `aibsgithub` | (Optional) GitHub service account username. |
| github_access_token | string | `N/A` | GitHub personal access token for nuget package access. |
| github_branch | string | `N/A` | (Mandatory) GitHub git branch. |
| github_repo | string | `N/A` | (Mandatory) GitHub git repo. |
| aws_account_id | string | `N/A` | (Mandatory) AWS account id where ecs service is deployed. |
| docker_username | string | `N/A` | (Mandatory) User name for Docker account used during build. |
| docker_login_token | string | `N/A` | (Mandatory) Docker login token for Docker account used during build. |
| ecs_service | string | `N/A` | (Mandatory) Name of ECS Service. |
| ecs_cluster | string | `N/A` | (Mandatory) Name of ECS Cluster. |
| ecs_container | string | `N/A` | (Mandatory) Name of ECS Container. |
| build_timeout | number | `10` | (Optional) Timeout for build in minutes. |
| project_build_spec | bool | `false` | (Optional) Indicates if build spec is included in root directory of project.  If not default build spec is used. |
| build_env_image | string | `aws/codebuild/standard:7.0` | (Optional) Docker image to use for this build project. |
| project_directory | string | `N/A` | (Mandatory) Project Directory not including src.  It is assumed for default build spec the project would be stored with convention... src/project_directory/project_directory.csproj.|  
| db_secret | string | `N/A` | (Mandatory) Name of database secret to pass to build spec. |
| environment_variables | list(object({name=string,value=string})) | `[]` | (Optional) List of additional environment variables to pass to build. |
| region | string | `N/A` | (Mandatory) AWS region where secret will be stored. |
| verification_stage | bool | `false` | (Optional) Add the verification stage to the pipeline. |
| verification_project_directory | string | `""` | (Optional) Directory of the verification project. Required if `verification_stage` is `true`. It is assumed for default build spec the project would be stored with convention... test/verification_project_directory/verification_project_directory.csproj. |
| verification_state_machine_arn | string | `""` | (Optional) Arn of the step function used for verification. Required if `verification_stage` is `true`. |
| verification_lambda_function_names | string | `""` | (Optional) Comma separated list as a string of the lambda function names. Required if `verification_stage` is `true`. |
| verification_lambda_bucket | string | `""` | (Optional) S3 bucket name containing the lambda package. Required if `verification_stage` is `true`. |
| verification_lambda_bucket_arn | string | `""` | (Optional) S3 bucket arn containing the lambda package. Required if `verification_stage` is `true`. |
| verification_lambda_s3_key | string | `""` | (Optional) S3 key of the lambda package. Required if `verification_stage` is `true`. |
| data_store_type | string | `rds` | (Mandatory) The only other available value is `neo4j`. Used to set ENV variables and decide which buildspec to use. |
| extra_buildspec_install_steps | `list(string)` | `[]` | (Optional) Additional installation steps to add to the buildspec. |
| vpc_config | list(object({security_group_ids=string,subnets=list(string),vpc_id=string})) | `N/A` | (Optional) provide VPC configuration to run the codebuild project(s) inside a VPC. Often need to reach endpoints (such as DBs) that are inside a private subnet.  It's strongly recommended to run the project inside a private subnet as well.  The subnet must have egress to the internet, however, unless sufficient VPC endpoints are available. The SG can usually deny all ingress. If null (default), project will be outside of VPC |
| codestar_connection_arn | string				| `N/A` | (Mandatory) GitHub codestar_connection_arn. |