# RDS

This module creates an RDS Postgres Instance with secret attachment and password rotation.  The database instance can either be created from scratch or loaded from a snapshot.  When loading a new snapshot, the new database from snapshot is created the secret attachment and secret are updated and then the previous database is deleted.

## Examples

```terraform
/*
 * These examples assume a variable has been defined that names the project and the project is setup where a VPC has been created.  Example below.
 */
variable "project_name" {
  description = "Name of project."
  type        = string
  default     = "dats"
}
module "dats_vpc" {
    source       = "github.com/AllenInstitute/platform-terraform-modules/vpc"
    project_name = var.project_name
}
```
```terraform
/*
 * Creates new RDS postgres instance
 */
module "dats_db" {
  source = "github.com/AllenInstitute/platform-terraform-modules/rds"
  project_name       = var.project_name
  database_name      = "${var.project_name}_main"
  database_username  = "${var.project_name}_admin"
  vpc_id             = module.dats_vpc.id
  vpc_public_subnets = module.dats_vpc.public_subnets
  region             = var.region
}
```
```terraform
/*
 * Creates RDS postgres instance from snapshot.
 */
module "dats_db" {
  source = "github.com/AllenInstitute/platform-terraform-modules/rds"
  project_name        = var.project_name
  database_name       = "${var.project_name}_main"
  database_username   = "${var.project_name}_admin"
  vpc_id              = module.dats_vpc.id
  vpc_public_subnets  = module.dats_vpc.public_subnets
  region              = var.region
  snapshot_identifier = "snapshot-identifier"
}
```

```terraform
/*
 * Creates RDS postgres instance with version specified.
 */
module "sfs_db" {
  source = "github.com/AllenInstitute/platform-terraform-modules/rds"
  project_name                         = var.project_name
  database_name                        = "${var.project_name}_main"
  database_username                    = "${var.project_name}_admin"
  database_engine_version              = "15"
  database_parameter_group_name        = "default.postgres15"
  database_instance_class              = "db.m6i.2xlarge"
  allocated_storage                    = 2000
  storage_type                         = "gp3"
  database_iops                        = 12000
  vpc_id                               = module.sfs_vpc.id
  vpc_public_subnets                   = module.sfs_vpc.public_subnets
  database_apply_immediately           = true
  database_allow_major_version_upgrade = true
  region                               = var.region
}
```

## Loading database from snapshot special consideration.
In most cases loading a database from snapshot does not require updating the database name and username.  This is because the snapshot being loaded is presumably being loaded from the same service.  If ever loading a database snapshot where the database name and/or database username is different, those variables should be updated in the module definition to ensure secret is connected correctly and terraform does not continue to recognize these items as changes.

## Variables
| name | type | default | description |
| --- | --- | --- | --- |
| project_name | string | `N/A` | (Mandatory) Name of project used for naming all resources. Maximum 41 characters. |
| vpc_id | string | `N/A` | (Mandatory) Id of VPC to where RDS instance is deployed. |
| vpc_public_subnets | string | `N/A` | (Mandatory) Subnet ids for subnet group for PostgreSQL database. |
| database_name | string | `N/A` | (Mandatory) Name of database. |
| database_user_name | string | `N/A` | (Mandatory) Database admin account name. |
| snapshot_identifier | string | `none` | (Optional) Optional Snapshot Identifier to load database. |
| database_port | number | `5432` | (Optional) TCP/IP Port for the Database Instance. |
| database_instance_class | string | `db.m5.large` | (Optional) Instance class for database instance. |
| allocated_storage | number | `200` | (Optional) The size of the database (GiB). |
| database_engine | string | `postgres` | (Optional) The name of the database engine to use for DB instance. |
| database_engine_version | string | `14` | (Optional) The engine version to use. If `auto_minor_version_upgrade` is enabled, you can provide a prefix of the version such as 14 (for 14.8) |
| database_iops | number | `null` | (Optional) The amount of provisioned IOPS. Setting this implies a storage_type of "io1". Can only be set when storage_type is "io1" or "gp3". Cannot be specified for gp3 storage if the allocated_storage value is below a per-engine threshold. |
| auto_minor_version_upgrade | bool | `true` | (Optional) A value that indicates whether minor engine upgrades are applied automatically to the DB instance during the maintenance window.|
| publicly_accessible | bool | `true` | (Optional) Indicates whether the DB instance is an internet-facing instance.|
| storage_type | string | `gp2` | (Optional) Specifies the storage type to be associated with the DB instance. |
| multi_az | bool | `false` | (Optional) Specifies whether the database instance is a multiple Availability Zone deployment.|
| storage_encrypted | bool | `true` | (Optional) A value that indicates whether the DB instance is encrypted.|
| backup_retention_period | number | `30` | (Optional) The number of days for which automated backups are retained. |
| skip_final_snapshot | bool | `true` | (Optional) Set whether DB snapshot is created before the DB instance is deleted.|
| password_rotation_interval | number | `30` | (Optional) A value that indicates how often to rotate password in days. |
| project_secret_values | map | {} | (Optional) Additional key values to add to database secret. |
| database_apply_immediately | bool | `false` | (Optional) Specifies whether any database modifications are applied immediately, or during the next maintenance window. |
| database_allow_major_version_upgrade | bool | `false` | (Optional) Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible. |
| database_parameter_group_name | string | `default.postgres14` | (Optional) Name of the DB parameter group to associate. |
| region | string | `N/A` | (Mandatory) AWS region where secret will be stored. |
