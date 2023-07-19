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

variable "step_function_description" {
  description = "The description of the step function."
  type        = string
}

variable "s3_key" {
  description = "AWS S3 location of the lambda package."
  type        = string
}

variable "service_url" {
  description = "Service URL to run smoke tests against."
  type        = string
}

variable "lambda_functions" {
  description = "Lambda function configuration details."
  type        = list(object({
    function_name  = string
    description    = string
    handler        = string
    runtime        = string
    memory_size    = number
    timeout        = number
    env_vars       = map(string)
  }))
}
