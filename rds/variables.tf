/*
 * Variables to support RDS.
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
  type        = list(any)
}

variable "database_name" {
  description = "Name of database"
  type        = string
}

variable "database_username" {
  description = "Database admin account name"
  type        = string
}

variable "snapshot_identifier" {
  description = "Optional Snapshot identifier to load database."
  type        = string
  default     = null
}

variable "database_port" {
  description = "TCP/IP Port for the Database Instance"
  type        = number
  default     = 5432
}

variable "database_instance_class" {
  description = "instance class for database instance"
  type        = string
  default     = "db.m5.large"
}

variable "allocated_storage" {
  description = "The size of the database (GiB)"
  type        = number
  default     = 200
}

variable "database_engine" {
  description = "The name of the database engine that you want to use for this DB instance."
  type        = string
  default     = "postgres"
}

variable "database_engine_version" {
  description = "(Optional) The engine version to use. If `auto_minor_version_upgrade` is enabled, you can provide a prefix of the version such as 14 (for 14.8)"
  type        = string
  default     = "14"
}

variable "database_iops" {
  description = "(Optional) The amount of provisioned IOPS. Setting this implies a storage_type of \"io1\". Can only be set when storage_type is \"io1\" or \"gp3\". Cannot be specified for gp3 storage if the allocated_storage value is below a per-engine threshold."
  type        = number
  default     = null
}

variable "auto_minor_version_upgrade" {
  description = "A value that indicates whether minor engine upgrades are applied automatically to the DB instance during the maintenance window."
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Indicates whether the DB instance is an internet-facing instance."
  type        = bool
  default     = true
}

variable "storage_type" {
  description = "Specifies the storage type to be associated with the DB instance."
  type        = string
  default     = "gp2"
}

variable "multi_az" {
  description = "Specifies whether the database instance is a multiple Availability Zone deployment."
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "A value that indicates whether the DB instance is encrypted."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "The number of days for which automated backups are retained."
  type        = number
  default     = 30
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
  type        = bool
  default     = true
}

variable "password_rotation_interval" {
  description = "A value that indicates how often to rotate password in days."
  type        = number
  default     = 30
}

variable "project_secret_values" {
  description = "Additional project specific key values to add to secret"
  type        = map(any)
  default     = {}
}

variable "database_apply_immediately" {
  description = "(Optional) Specifies whether any database modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = false
}

variable "database_allow_major_version_upgrade" {
  description = "(Optional) Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible."
  type        = bool
  default     = false
}

variable "database_parameter_group_name" {
  description = "(Optional) Name of the DB parameter group to associate."
  type        = string
  default     = "default.postgres14"
}

variable "region" {
  description = "Region."
  type        = string
}
