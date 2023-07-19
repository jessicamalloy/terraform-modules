module "secrets_manager" {
  source        = "github.com/AllenInstitute/platform-terraform-modules/secrets-manager"
  name_prefix   = "terraform"
  secret_string = jsonencode(local.docker_credentials)
  description   = "Docker credentials"

  enable_rotation = false

  tags = {
    Name        = "${var.project_name}-docker-secret"
    ProjectName = var.project_name
  }
}