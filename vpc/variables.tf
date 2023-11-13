variable "project_name" {
  description = "Name of project."
  type        = string
  validation {
    condition     = length(var.project_name) < 42
    error_message = "Maximum length for project name is 41."
  }
}

variable "create_private_subnets" {
  description = "Indicates if private subnets should be created in addition to public subnets."
  type        = bool
  default     = true
}

variable "number_of_azs" {
  description = "Specify number of Availability Zones to use."
  type        = number
  default     = 3
}

variable "create_private_eip" {
  description = "Whether or not to add an elastic IP to the nat gateway for private subnets"
  type        = bool
  default     = true
}

variable "cidr_block" {
  description = "(Optional) Specific CIDR block to use for VPC. Defaults to 10.0.0.0/16"
  type        = string
  default     = "10.0.0.0/16"
}
