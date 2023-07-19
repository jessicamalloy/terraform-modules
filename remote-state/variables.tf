variable "dynamo_name" {
  description = "The name to use for DynamoDB"
  type        = list(string)
}

variable "s3_bucket_name" {
  description = "The name to use for the S3 bucket"
  type        = string
}