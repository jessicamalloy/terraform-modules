/*
 * Variables to support ECS.
 */

variable "project_name" {
  description = "Name of project."
  type        = string
  validation {
    condition     = length(var.project_name) < 42
    error_message = "Maximum length for project name is 41."
  }
}

variable "vpc_id" {
  description = "Id for VPC"
  type        = string
}

variable "vpc_public_subnets" {
  description = "Name of project."
  type        = list
}

variable "domain_name" {
  description = "Domain name registered from AWS Route 53 used as basename for the API URL to the deployed service."
  type        = string
}
 
variable "aws_account_id" {
  description = "AWS Account ID: 245669007660"
  type        = string
}

variable "region" {
  description = "Region."
  type        = string
}

variable "application_port" {
  description = "The port number the application in the container is running on."
  type        = number
  default     = 80
}

variable "env_vars" {
  description = "Environment variables"
  type        = list
  default     = []
}

variable "ecs_task_def_cpu" {
  description = "The number of cpu units used by the task."
  type        = number
  default     = 4096
}

variable "ecs_task_def_memory" {
  description = "The amount (in MiB) of memory used by the task."
  type        = number
  default     = 30720
}

variable "ecs_desired_task_count" {
  description = "The number of task definition to place and keep running on the cluster."
  type = string
  default = 2
}

variable "project_managed_policy_arns" {
  description = "Used to add additional policy arns to ECS task role. "
  type        = list
  default     = []
}

variable "project_ingress_with_cidr_blocks" {
  description = "Used to add additional ingress rules for ECS task security group."
  type        = list
  default     = []
}
