/*
 * Add initial db credentials
 */
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*"
}

locals {
  db_creds = merge(
    {
      username = var.database_username
      password = random_password.password.result
    },
    var.project_secret_values
  )
}
