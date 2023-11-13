# ECS

This module creates an Elastic Container Service using Fargate launch type.  The service is setup with a AWS Application Load Balancer.

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
 * Creates new ECS using fargate launch type with default settings.  This example adds one custom environment variable for the secret id containing database information.
 */
module "dats_ecs" {
  source = "github.com/AllenInstitute/platform-terraform-modules/ecs"
  project_name       = var.project_name
  domain_name        = "myDomainName.net"
  aws_account_id     = "awsAccountId"
  region             = "us-west-2"
  vpc_id             = module.dats_vpc.id
  vpc_public_subnets = module.dats_vpc.public_subnets

  env_vars = [
    { 
      "name": "DB_SECRET", 
      "value": "${module.dats_db.db_secret_id}" 
    }
  ]
}
```
```terraform
/*
 * Creates new ECS using fargate launch type with default settings.  Additional project setting to open inbound ports to all.
 */
module "dats_ecs" {
  source = "github.com/AllenInstitute/platform-terraform-modules/ecs"
  project_name       = var.project_name
  domain_name        = "myDomainName.net"
  aws_account_id     = "awsAccountId"
  region             = "us-west-2"
  vpc_id             = module.dats_vpc.id
  vpc_public_subnets = module.dats_vpc.public_subnets
  project_ingress_with_cidr_blocks = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = "0.0.0.0/0"
    }
  ]
}
```

## ACM Consideration:
The ACM certificate created for this service will require a one-time validation.  To validate the ACM certificate when creating the service for the first time:
1. Navigate to AWS certificate manager.
2. Click the carrot next to domain name <project_name.domain_name>
3. In status section click carrot next to domain name.
4. Click create record in route 53 button. 


## Variables
| name | type | default | description |
| --- | --- | --- | --- |
| project_name | string | `N/A` | (Mandatory) Name of project used for naming all resources. Maximum 41 characters. |
| vpc_id | string | `N/A` | (Mandatory) Id of VPC to where ECS is deployed. |
| vpc_public_subnets | string | `N/A` | (Mandatory) Subnet ids used by the ECS. |
| domain_name | string | `N/A` | (Mandatory) Domain name registered from AWS Route 53 used as basename for the API URL to the deployed service. |
| aws_account_id | string | `N/A` | (Mandatory) AWS account id where service is deployed. |
| application_port | number | `4000` | (Optional) The port number the application in the container is running on. |
| env_vars | list | [] | (Optional) List of key value pairs for adding environment variables to service. |
| ecs_task_def_cpu | number | `4096` | (Optional) The number of cpu units used by the task. |
| ecs_task_def_memory | number | `30720` | (Optional) The amount (in MiB) of memory used by the task. |
| ecs_desired_task_count | number | `2` | (Optional) The number of task definition to place and keep running on the cluster. |
| project_managed_policy_arns | list | [] | (Optional) Used to add additional policy arns to ECS task role. |
| project_ingress_with_cidr_blocks | list | [] | (Optional) Used to add additional ingress rules for ECS task security group. |
| region | string | `N/A` | (Mandatory) AWS region where secret will be stored. |
