module "secrets_manager" {
  source        = "..//secrets-manager"
  name_prefix   = "terraform"
  secret_string = jsonencode(local.docker_credentials)
  description   = "Docker credentials"
  recovery_window_in_days = 0

  enable_rotation = false

  tags = {
    Name        = "${var.project_name}-docker-secret"
    ProjectName = var.project_name
  }
}
