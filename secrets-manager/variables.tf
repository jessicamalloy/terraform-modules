variable "create_secret" {
  type        = bool
  description = "(Optional) Whether or not to create a secret."
  default     = true
}

variable "name" {
  type        = string
  description = <<-EOT
  (Optional) Specifies the friendly name of the new secret. 
  The secret name can consist of uppercase letters, lowercase 
  letters, digits, and any of the following characters: `/_+=.@-` 
  Conflicts with `name_prefix`.
  EOT
  default     = null
}

variable "name_prefix" {
  type        = string
  description = <<-EOT
  (Optional) Creates a unique name beginning with the specified 
  prefix. Conflicts with `name`.
  EOT
  default     = "terraform"
}

variable "description" {
  type        = string
  description = "(Optional) A description of the secret."
  default     = null
}

variable "kms_key_id" {
  type        = string
  description = <<-EOT
  (Optional) Specifies the ARN or alias of the AWS KMS 
  customer master key (CMK) to be used to encrypt the 
  secret values in the versions stored in this secret. 
  If you don't specify this value, then Secrets Manager 
  defaults to using the AWS account's default CMK (the 
  one named `aws/secretsmanager`). If the default KMS CMK 
  with that name doesn't yet exist, then AWS Secrets 
  Manager creates it for you automatically the first time.
  EOT
  default     = null
}

variable "policy" {
  type        = any
  description = <<-EOT
  (Optional) A valid JSON document representing a resource 
  policy. For more information about building AWS IAM policy 
  documents with Terraform, see the `AWS IAM Policy Document Guide`.
  EOT
  default     = null
}

variable "recovery_window_in_days" {
  type        = number
  description = <<-EOT
  (Optional) Specifies the number of days that AWS Secrets Manager 
  waits before it can delete the secret. This value can be 0 to force 
  deletion without recovery or range from `7` to `30` days. The default 
  value is `30`.
  EOT
  default     = 30
}

variable "secret_string" {
  type        = string
  description = <<-EOT
  (Optional) Specifies text data that you want to encrypt and store in this 
  version of the secret. This is required if secret_binary is not set.
  EOT
  default     = null
}

variable "secret_binary" {
  type        = any
  description = <<-EOT
  (Optional) Specifies binary data that you want to encrypt and store in this version of 
  the secret. This is required if secret_string is not set. Needs to be encoded 
  to base64.
  EOT
  default     = null
}

variable "lambda_rotation_arn" {
  type        = string
  description = <<-EOT
  (Optional) Specifies the ARN of the Lambda function that can rotate the secret.
  (e.g. "arn:aws:lambda:us-east-2:123456789012:function:my-function:1")
  EOT
  default     = null
}

variable "rotate_automatically_after_days" {
  type        = number
  description = <<-EOT
  (Optional) Specifies the number of days between automatic scheduled rotations of 
  the secret.
  EOT
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = <<-EOT
  (Optional) Specifies a key-value map of user-defined tags that are attached to 
  the secret.
  EOT
  default     = {}
}

variable "enable_rotation" {
  type        = bool
  description = "(Optional) Whether or not to enable rotation on secret."
  default     = false
}
