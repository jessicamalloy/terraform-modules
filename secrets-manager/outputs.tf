output "secret_id" {
  value       = var.create_secret ? aws_secretsmanager_secret.secret[0].id : null
  description = "The identifier (ARN) of the secret."
}

output "secret_arn" {
  value       = var.create_secret ? aws_secretsmanager_secret.secret[0].arn : null
  description = "The ARN of the secret."
}

output "version_id" {
  value       = var.create_secret ? aws_secretsmanager_secret_version.secret_version[0].version_id : null
  description = "The unique identifier of this version of the secret."
}

output "rotation_enabled" {
  value       = var.create_secret && length(aws_secretsmanager_secret_rotation.rotation) > 0
  description = "Whether or not secrets rotation is enabled."
}
