# ECS Code Build

This module creates a CodeBuild build and deploy a platform ECS service. This is intended to be used with our ecs-codepipeline module.

## VPC Considerations

The `vpc_config` list(object) variable can be used to place the codepipeline 
build projects within a VPC. This is often needed to manage resources that are
placed in the same VPC (such as RDS databases). As a best practice, it's
recommended to place the pipeline inside of a private subnet. The majority of
the time, the provided security group can deny all ingress but must allow
egress for the required endpoints.

See example in next section below.

## Examples



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
| github_username | string | `aibsgithub` | (Optional) GitHub service account username. |
| github_access_token | string | `N/A` | GitHub personal access token for nuget package access. |
| aws_account_id | string | `N/A` | (Mandatory) AWS account id where ecs service is deployed. |
| docker_secret_id | string | `N/A` | (Mandatory) The secret id of where docker credentials are stored. |
| build_timeout | number | `10` | (Optional) Timeout for build in minutes. |
| buildspec | string | `N/A` | (Mandatory) File contents of the buildspec. |
| build_env_image | string | `aws/codebuild/standard:7.0` | (Optional) Docker image to use for this build project. |
| environment_variables | list(object({name=string,value=string})) | `[]` | (Optional) List of additional environment variables to pass to build. |
| region | string | `N/A` | (Mandatory) AWS region where secret will be stored. |
| vpc_config | list(object({security_group_ids=string,subnets=list(string),vpc_id=string})) | `N/A` | (Optional) provide VPC configuration to run the codebuild project(s) inside a VPC. Often need to reach endpoints (such as DBs) that are inside a private subnet.  It's strongly recommended to run the project inside a private subnet as well.  The subnet must have egress to the internet, however, unless sufficient VPC endpoints are available. The SG can usually deny all ingress. If null (default), project will be outside of VPC |
