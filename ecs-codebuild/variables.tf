variable "project_name" {
  description = "Name of project."
  type        = string
  validation {
    condition     = length(var.project_name) < 42
    error_message = "Maximum length for project name is 41."
  }
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

variable "buildspec" {
  description = "File contents of the buildspec."
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

variable "docker_secret_id" {
  description = "Secret ID of Docker credentials."
  type        = string
}

variable "build_env_image" {
  description = "Docker image to use for this build project"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "build_timeout" {
  description = "Timeout for build in minutes"
  type        = number
  default     = 10
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

variable "s3_bucket_resources" {
  description = "List of additional s3 bucket resources that codebuild needs access to."
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
