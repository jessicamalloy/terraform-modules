# Smoke Test SFN

This module creates a Step Function to run smoke test lambda functions in parallel.

Lambda functions cannot take any input, but can use environment variables instead. As the intent of this module is to use lambda functions that test a service, they should generally all use the `SERVICE_URL` environment variable, which will be defined by the `service_url` module variable. All the lambda functions should be packaged together and in the same AWS S3 key defined by `s3_key`.

## Examples

This example assumes a platform ECS service has been created for the "dats" project using modules, vpc, ecs, and rds.  This is only an example and is assumed that sensitive variables like tokens would not be stored directly in the module definition.

```terraform
module "smoke_test_sfn" {
  source = "github.com/AllenInstitute/platform-terraform-modules/smoke-test-sfn"
  project_name              = var.project_name
  aws_account_id            = var.aws_account_id
  region                    = var.region
  step_function_description = "Smoke Tests for Digital Asset Tracking Service"
  s3_key                    = "SmokeTests.zip"
  service_url               = module.dats_ecs.service_url
  lambda_functions          = [
    {
      function_name  = "HealthCheck"
      description    = "Checks the health of the service"
      handler        = "DigitalAssetTrackingSmokeTests::DigitalAssetTrackingSmokeTests.SmokeTestTasks::HealthCheck"
      runtime        = "dotnet6"
      memory_size    = 128
      timeout        = 30
      env_vars       = {}
    }
  ]
}
```

## Variables

| name | type | default | description |
| --- | --- | --- | --- |
| project_name | string | `N/A` | (Mandatory) Name of project used for naming all resources. Maximum 41 characters. |
| aws_account_id | string | `N/A` | (Mandatory) AWS account id where ecs service is deployed. |
| region | string | `N/A` | (Mandatory) AWS region where secret will be stored. |
| step_function_description | string | `N/A` | (Mandatory) The description of the step function. |
| s3_key | string | `N/A` | (Mandatory) AWS S3 location of the lambda package. |
| service_url | string | `N/A` | (Mandatory) Service URL to run smoke tests against. |
| lambda_functions | list(object({function_name=string,description=string,handler=string,runtime=string,memory_size=number,timeout=number,env_vars=map(string)})) | `N/A` | (Mandatory) Lamda function configuration details. |

## Outputs

| name | type | description |
| --- | --- | --- |
| arn | string | State machine arn. |
| lambda_bucket | string | Lambda bucket name. |
| lambda_bucket_arn | string | Lambda bucket arn. |
| function_names | list(string) | List of lambda function names. |
