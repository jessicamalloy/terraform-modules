variable "project_name" {
  description = "Name of project."
  type        = string
  validation {
    condition     = length(var.project_name) < 42
    error_message = "Maximum length for project name is 41."
  }
}

variable "buildspec" {
  description = "File contents of the buildspec."
  type        = string
}

variable "github_oauth_token" {
  description = "OAuth token allowing access to repository."
  type        = string
  sensitive   = true
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

variable "build_timeout" {
  description = "Timeout for build in minutes"
  type        = number
  default     = 10
}

variable "build_env_image" {
  description = "Docker image to use for this build project"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "environment_variables" {
  description = "List of additional environment variables to pass to build."
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  default = []
}

variable "pipeline_stages" {
  description = "List of additional stages in the pipeline"
  type = list(object({
    name            = string
    action_name     = string
    action_category = string
    action_owner    = string
    action_provider = string
    action_version  = string
    configuration   = map(string)
  }))
  default = []
}

variable "s3_bucket_resources" {
  description = "List of additional s3 bucket resources that codebuild needs access to."
  type        = list(string)
  default     = []
}
