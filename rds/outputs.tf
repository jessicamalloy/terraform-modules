/*
 * Returns secret id for database.
 */
output "db_secret_id" {
  value = module.secrets_manager.secret_id
}

output "db_instance_id" {
  value = aws_db_instance.main.id
}
