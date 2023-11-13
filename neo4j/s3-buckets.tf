resource "aws_s3_bucket" "backup_bucket" {
  bucket = "${var.project_name}-neo4j-nightly-backups"

  tags = {
    ProjectName = var.project_name
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backup_bucket_expiration_rule" {
  bucket = aws_s3_bucket.backup_bucket.id

  rule {
    id = "${var.project_name}-neo4j-nightly-backups-removal"

    filter {
        prefix = "backups/neo4j_"
    }

    expiration {
        days = var.backup_expiration_days
      }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "backup_bucket_restrict_public_access" {
  bucket = aws_s3_bucket.backup_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
