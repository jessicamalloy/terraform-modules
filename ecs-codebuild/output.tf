output "project_bucket" {
  value = aws_s3_bucket.project_bucket
}

output "repository_arn" {
  value = aws_ecr_repository.ecr_repo.arn
}
