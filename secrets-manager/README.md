# Secrets Managers

This module creates a secret in AWS Secrets Manager.

Optionally, you can enable secret rotation through an AWS Lambda function.

## Examples

#### Default

```terraform
module "secrets_manager" {
    source = "github.com/AllenInsitute/platform-terraform-modules/secrets-manager"

    name_prefix   = "terraform"
    secret_string = jsonencode({name = "Allen Institute"})

    tags = {
        Environment = "stage"
    }
}
```

#### Secret Rotation

```terraform
module "secrets_manager" {
    source = "github.com/AllenInsitute/platform-terraform-modules/secrets-manager"

    name_prefix   = "terraform"
    secret_string = jsonencode({name = "Allen Institute"})

    lambda_rotation_arn             = "arn:aws:lambda:us-east-2:123456789012:function:my-function:1"
    rotate_automatically_after_days = 15

    tags = {
        Environment = "stage"
    }
}
```

## Variables
| name | type | default | description |
| --- | --- | --- | --- |
| create_secret | bool | `true` | (Optional) Whether or not to create a secret. |
| name | string | `null` | (Optional) Specifies the friendly name of the new secret. The secret name can consist of uppercase letters, lowercase letters, digits, and any of the following characters: `/_+=.@-` Conflicts with `name_prefix`. |
| name_prefix | string | `"terraform"` | (Optional) Creates a unique name beginning with the specified prefix. Conflicts with `name`. |
| description | string | `null` | (Optional) A description of the secret. |
| kms_key_id | string | `null` | (Optional) Specifies the ARN or alias of the AWS KMS  customer master key (CMK) to be used to encrypt the secret values in the versions stored in this secret. If you don't specify this value, then Secrets Manager defaults to using the AWS account's default CMK (the one named `aws/secretsmanager`). If the default KMS CMK with that name doesn't yet exist, then AWS Secrets Manager creates it for you automatically the first time. |
| policy | string | `null` | (Optional) A valid JSON document representing a resource policy. For more information about building AWS IAM policy documents with Terraform, see the `AWS IAM Policy Document Guide`. |
| recovery_window_in_days | number | `30` | (Optional) Specifies the number of days that AWS Secrets Manager waits before it can delete the secret. This value can be 0 to force deletion without recovery or range from `7` to `30` days. The default value is `30`. |
| secret_string | string | `null` | (Optional) Specifies text data that you want to encrypt and store in this version of the secret. This is required if secret_binary is not set. |
| secret_binary | any | `null` | (Optional) Specifies binary data that you want to encrypt and store in this version of the secret. This is required if secret_string is not set. Needs to be encoded to base64. |
| enable_rotation | bool | `false` | (Optional) Whether or not to enable rotation on secret. |
| lambda_rotation_arn | string | `null` | (Optional) Specifies the ARN of the Lambda function (e.g."arn:aws:lambda:us-east-2:123456789012:function:my-function:1") that can rotate the secret.  This should be provided if enable_roation is set to true |
| rotate_automatically_after_days | number | `30` | (Optional) Specifies the number of days between automatic scheduled rotations of the secret. |
| tags | map(string) | `{}` | (Optional) Specifies a key-value map of user-defined tags that are attached to the secret. |
