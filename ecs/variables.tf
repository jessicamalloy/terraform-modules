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
  description = "Public Subnet ids"
  type        = list(any)
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
  type        = list(any)
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
  type        = string
  default     = 2
}

variable "project_managed_policy_arns" {
  description = "Used to add additional policy arns to ECS task role. "
  type        = list(any)
  default     = []
}

variable "project_ingress_with_cidr_blocks" {
  description = "Used to add additional ingress rules for ECS task security group."
  type        = list(any)
  default     = []
}

variable "certificate_authority_arn" {
  description = "(Conditional) arn of customer-managed certificate authority. If empty, uses DNS validation. Required if use_certificate_authority is true"
  type        = string
  default     = null
}

variable "use_certificate_authority" {
  description = "(Optional) whether to use certificate authority (default true). If true, certificate_authority_arn MUST also be provided."
  type        = bool
  default     = true
}

variable "subject_alternative_names" {
  description = "(Optional) Set of domains that should be SANs in the issued certificate. To remove all elements of a previously configured list, set this value equal to an empty list ([])"
  type        = list(string)
  default     = null
}

variable "hosted_zone_names" {
  type        = list(string)
  default     = null
  description = <<EOF
    (optional) List of domain names to create private hosted zones. If not provided, uses 
    data source to look up zone for domain provided in domain_name variable. If
    provided, must be in SUBDOMAIN order. For example, if creating zones for
    sub2.sub1.domain.com and all its parents, provide the list:

    ["sub2.sub1.domain.com", "sub1.domain.com", "domain.com"].
    
    Any domains left out of the list will be assumed to already exist. No
    validation is run on the order of the domains, so this will simpy fail if
    not provided in order.

    The FIRST domain in the list will be used as the hosted zone for the created
    ACM certificates.
  EOF
}

variable "task_role_arn" {
  description = "Task role arn to be used for ecs task definition"
  type        = string
  default     = ""
}

variable "execution_role_arn" {
  description = "Execution role arn to be used for ecs task"
  type        = string
  default     = ""
}

# Additonal task def input variable, This is an optional task def may not be needed for all ecs services
variable "additional_task_def" {
  description = <<EOF
    (optional) Additional task def to create. This will not be deployed part of ECS Service.
    But if you need any tasks that needs run from ecs service. This task def can be used to create an ECS service and run
    as a batch job. Example data
    {
      "name" = "additional task def name",
      "execution_role_arn" = "additional task def execution role",
      "task_role_arn" = "additional task def role",
      "ecs_task_def_cpu" = "CPU",
      "ecs_task_def_memory" = "Memory",
      "ecs_container_name" = "container name",
      "tag_name" = "tag name of the additional task image in the Application ECR Repo",
      "container_port" = "Port Number this will be used as container port",
      "hostrport" = "Port Number this will be used as host port",
      "env_vars" = "List of objects with name and value attributes"      
    }
  EOF
  type        = object({
    name = string
    execution_role_arn = string
    task_role_arn = string
    ecs_task_def_cpu = number
    ecs_task_def_memory = number
    ecs_container_name = string
    tag_name = string
    container_port = number
    host_port = number
    env_vars = list(object({
      name = string
      value = string
    }))

  })
  default  = null
}
