variable "project_name" {
  description = "Name of project."
  type        = string
  validation {
    condition     = length(var.project_name) < 42
    error_message = "Maximum length for project name is 41."
  }
}

variable "github_owner" {
  description = "GitHub repo owner."
  type        = string
  default     = "AllenInstitute"
}

variable "github_branch" {
  description = "GitHub git branch."
  type        = string
}

variable "github_repo" {
  description = "GitHub git repo."
  type        = string
}

variable "github_username" {
  description = "GitHub service account username."
  type        = string
  default     = "aibsgithub"
}

variable "github_access_token" {
  description = "GitHub personal access token for nuget package access."
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID."
  type        = string
}

variable "region" {
  description = "Region."
  type        = string
  default     = "us-west-2"
}

variable "docker_username" {
  description = "User name for Docker account used during build."
  type        = string
}

variable "docker_login_token" {
  description = "Docker login token for Docker account used in build"
  type        = string
}

variable "ecs_service" {
  description = "Name of ECS Service"
  type        = string
}

variable "ecs_cluster" {
  description = "Name of ECS Cluster"
  type        = string
}

variable "ecs_container" {
  description = "Name of ECS Container"
  type        = string
}

variable "build_timeout" {
  description = "Timeout for build in minutes"
  type        = number
  default     = 10
}

variable "project_build_spec" {
  description = "Indicates if build spec is included in root directory of project.  If not default build spec is used."
  type        = bool
  default     = false
}

variable "build_env_image" {
  description = "Docker image to use for this build project"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "project_directory" {
  description = "Directory of the project."
  type        = string
}

variable "db_secret" {
  description = "Secret Id to access main db secret."
  type        = string
}

variable "environment_variables" {
  description = "List of additional environment variables to pass to build."
  type = list(object({
    name  = string
    value = string
    type = string
  }))
  default = []
}

variable "verification_stage" {
  description = "Add the verification stage to the pipeline."
  type        = bool
  default     = false
}

variable "verification_project_directory" {
  description = "Directory of the verification project."
  type        = string
  default     = ""
}

variable "verification_state_machine_arn" {
  description = "Arn of the step function used for verification."
  type        = string
  default     = ""
}

variable "verification_lambda_function_names" {
  description = "Comma separated list as a string of the lambda function names."
  type        = string
  default     = ""
}

variable "verification_lambda_bucket" {
  description = "S3 bucket name containing the lambda package."
  type        = string
  default     = ""
}

variable "verification_lambda_bucket_arn" {
  description = "S3 bucket arn containing the lambda package."
  type        = string
  default     = ""
}

variable "verification_lambda_s3_key" {
  description = "S3 key of the lambda package."
  type        = string
  default     = ""
}

variable "data_store_type" {
  description = "Either rds or neo4j. Used to set env variables."
  type        = string
  default     = "rds"
  validation {
    condition     = var.data_store_type == "rds" || var.data_store_type == "neo4j"
    error_message = "Valid options are 'rds' or 'neo4j' only."
  }
}

variable "extra_buildspec_install_steps" {
  description = "Additional installation steps to add to the buildspec."
  type        = list(string)
  default     = []
}

variable "vpc_config" {
  description = <<EOF
    (Optional) provide VPC configuration to run the codebuild project(s) inside a VPC. 
    Often need to reach endpoints (such as DBs) that are inside a private subnet. 
    It's strongly recommended to run the project inside a private subnet as well. 
    The subnet must have egress to the internet, however. The SG can usually deny all ingress. 
    If null (default), project will be outside of VPC
  EOF
  type = object({
    security_group_ids = list(string)
    subnets            = list(string)
    vpc_id             = string
  })
  default = null
}

variable "buildspec_dir" {
  type    = string
  default = null
}
variable "codestar_connection_arn" {
  type    = string
  default = null
}
