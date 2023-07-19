resource "aws_s3_bucket" "terraform_state" {
  # Name of bucket needs to be unique across all AWS customers
  bucket = var.s3_bucket_name

  # Don't allow bucket to be destroyed if it is not empty.
  # This is important so that the state file is not accidently deleted.
  force_destroy = false

  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  count        = length(var.dynamo_name)
  name         = var.dynamo_name[count.index]
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}