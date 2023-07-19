# VPC

This module creates an AWS VPC with a range of 1 (public) to 6 subnets (3 public, 3 private) across 3 Availability Zones.

## Examples

```terraform
/*
 * Create aws VPC "dats-VPC" with 3 avaliability zones 6 subnets (3 public 3 private)
 */
module "dats_vpc" {
    source       = "github.com/AllenInsitute/platform-terraform-modules/vpc"
    project_name = 'dats'
}
```
```terraform
/*
 * Create aws VPC "cell-service-VPC" with 3 avaliability zones 3 subnets (3 public 0 private)
 */
module "cell_service_vpc" {
    source                 = "github.com/AllenInsitute/platform-terraform-modules/vpc"
    project_name           = 'cell-service'
    create_private_subnets = false
}
```
```terraform
/*
 * Create aws VPC "process-service-VPC" with 2 avaliability zones 4 subnets (2 public 2 private)
 */
module "process_service_vpc" {
    source        = "github.com/AllenInsitute/platform-terraform-modules/vpc"
    project_name  = 'process-service'
    number_of_azs = 2
}
```

## Variables
| name | type | default | description |
| --- | --- | --- | --- |
| project_name | string | `N/A` | (Mandatory) Name of project used for naming all resources. Maximum 41 characters. |
| create_private_subnets | bool | `true` | (Optional) Indicates if private subnets should be created in addition to public subnets.|
| number_of_azs | number | `3` | (Optional) Specify number of Availability Zones to use. Max 3|
