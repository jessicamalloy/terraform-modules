variable "project_name" {
  description = "Name of project."
  type        = string
  validation {
    condition     = length(var.project_name) < 42
    error_message = "Maximum length for project name is 41."
  }
}

variable "ami" {
  description = <<-EOT
  The instance AMI. Must be a Ubuntu image.
  Default is ubuntu-jammy-22.04-amd64-server
  EOT
  type        = string
  default     = "ami-0735c191cf914754d"
}

variable "neo4j_edition" {
  description = <<-EOT
  The edition of Neo4j to get from AWS AMI
  (e.g. community or enterprise)
  EOT
  type        = string
  default     = "community"
}

variable "neo4j_version" {
  description = "Version of Neo4j to install from AWS AMI."
  type        = string
  default     = "4.4.3"
}

variable "neo4j_instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "r4.large"
}

variable "neo4j_volume_type" {
  description = "What kind of storage to attach."
  type        = string
  default     = "gp2"
}

variable "neo4j_volume_size_gb" {
  description = <<-EOT
  How much EBS storage is allocated to each cluster
  node, in GiB.
  EOT
  type        = number
  default     = 100
}

variable "domain_name" {
  description = "Domain name registered from AWS Route 53 used as basename for the Neo4j deployed server."
  type        = string
}

variable "project_secret_values" {
  description = "Additional project specific key values to add to secret"
  type = map
  default = {}
}

variable "vpc_id" {
  description = "Id for VPC"
  type        = string
}

variable "vpc_public_subnets" {
  description = "Subnet ids for subnet group for Neo4j."
  type        = list
}

variable "vpc_private_subnets" {
  description = "Private Subnet ids for subnet group for Neo4j."
  type        = list
}

variable "cloudwatch_retention_days" {
  description = "Number of days to keep cloudwatch logs."
  type        = number
  default     = 14
}

variable "backup_expiration_days" {
  description = "Number of days to keep neo4j backups in S3 bucket."
  type        = number
  default     = 10
}

variable "region" {
  description = "Region."
  type        = string
}

variable "https_port" {
  description = "Port used by Neo4j Browser."
  type        = number
  default     = 7473
}

variable "bolt_port" {
  description = "Port used by Cypher Shell, Neo4j Browser, and the official Neo4j drivers."
  type        = number
  default     = 7687
}
