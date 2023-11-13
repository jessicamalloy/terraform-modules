variable "name" {
  description = "Name of the service"
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "desired_count" {
  description = "Desired number of tasks to run for the service"
  type        = number
  default     = 1
}

variable "image" {
  description = "Image for the service"
  type        = string
}

variable "cpu" {
  description = "CPU for the service"
  type        = number
}

variable "memory" {
  description = "Memory for the service"
  type        = number
}

variable "essential" {
  description = "Whether or not the service is essential"
  type        = bool
  default     = true
}

variable "security_groups" {
  description = "List of security group ids for the service"
  type        = list(string)
}

variable "subnets" {
  description = "List of subnet ids for the service"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether or not to assign a public IP to the service"
  type        = bool
  default     = false
}

variable "task_role_arn" {
  description = "Task role arn"
  type        = string
  default     = ""
}

variable "execution_role_arn" {
  description = "Execution role arn"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "Name of the cloudwatch log group"
}

variable "cloudwatch_stream_prefix" {
  description = "Prefix of the cloudwatch stream"
}

variable "cloud_watch_retention" {
  description = "Retention (in days) of the cloudwatch logs"
  default = 14
}

variable "environment_vars" {
  description = "List of environment variables"
  type = list(object({
    name  = string
    value = string
    type = string
  }))
  default = []
}

variable "port_mappings" {
  description = "List of port mappings"
  type = list(object({
    containerPort = number
  }))
  default = []
}

variable "secrets" {
  description = "List of secrets"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "service_registries" {
  description = "Service discovery registries"
  type = list(object({
    registry_arn = string
  }))
  default = []
}

variable "load_balancer" {
  description = "Load balancer settings"
  type = list(object({
    target_group_arn = string
    container_port   = number
  }))
  default = []
}
