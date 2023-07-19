# Neo4j

This module creates an EC2 Instance using a Neo4j AMI.<br />
When creating the new EC2, the neo4j instance is configured to forward the following logs to cloudwatch:
- amazon-cloudwatch-agent.log
- neo4j-nightly-backup.log
- neo4j-setup.log
- neo4j.log
- debug.log

Installs plugins neosemantics (n10s) and apoc plugins.<br /> 
A cron job is set up to perform a data backup every night at 1:00 AM (PST). S3 bucket "${var.project_name}-neo4j-nightly-backups" holds the dump file, the bucket 
has a lifecycle that keeps the latest 10 backups.<br />
Note, `neo4j-tools` funtions are created to help with backing up and restoring the graph.

### Using Neo4j community edition considerations.
Using Neo4j community edition limits the number of users and machines to be used. Only a single user and a single machine 
can be used. This module uses 'neo4j' for database name and user to simplify configuration of the EC2 instance, since 'neo4j'
is used by default. Also, scripts to run nightly backups rely on the database name being 'neo4j'.

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
module "bers_vps" {
    source       = "github.com/jessicamalloy/terraform-modules/vpc"
    project_name = var.project_name
}
```
```terraform
/*
 * Creates new Neo4j EC2 instance
 */
module "bers_neo4j" {
  source = "github.com/jessicamalloy/terraform-modules/neo4j"
  project_name       = var.project_name
  domain_name        = var.domain_name
  vpc_id             = module.bers_vpc.id
  vpc_public_subnets = module.bers_vpc.public_subnets
  vpc_private_subnets= module.bers_vpc.private_subnets
  region             = var.region
}
```

## Variables
| name | type | default | description |
| --- | --- | --- | --- |
| project_name | string | `N/A` | (Mandatory) Name of project used for naming all resources. Maximum 41 characters. |
| neo4j_edition | string | `community` | (Optional) The edition of Neo4j to get from AWS AMI. |
| neo4j_version | string | `4.4.3` | (Optional) Version of Neo4j to install from AWS AMI. |
| neo4j_instance_type | string | `r4.large` | (Optional) EC2 instance type. |
| neo4j_volume_type | string | `gp2` | (Optional) What kind of storage to attach. |
| neo4j_volume_size_gb | number | `100` | (Optional) How much EBS storage is allocated to each cluster node, in GiB. |
| vpc_id | string | `N/A` | (Mandatory) Id of VPC to where RDS instance is deployed. |
| vpc_public_subnets | string | `N/A` | (Mandatory) Subnet ids for subnet group for Neo4j. |
| vpc_private_subnets | string | `N/A` | (Mandatory) Subnet ids for subnet group for Neo4j. |
| domain_name | string | `N/A` | (Mandatory) Domain name registered from AWS Route 53 used as basename for the Neo4j deployed server. |
| https_port | number | `7473` | (Optional) TCP/IP Port used by Neo4j Browser. |
| bolt_port | number | `7487` | (Optional) TCP/IP Port used by Cypher Shell, Neo4j Browser, and the official Neo4j drivers. |
| cloudwatch_retention_days | number | `14` | (Optional) Number of days to keep cloudwatch logs. |
| backup_expiration_days | number | `10` | (Optional) Number of days to keep neo4j backups in S3 bucket. |
| project_secret_values | map | {} | (Optional) Additional key values to add to database secret. |
| region | string | `N/A` | (Mandatory) AWS region where secret will be stored. |
