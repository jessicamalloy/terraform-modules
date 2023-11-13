module "secrets_manager" {
  source        = "..//secrets-manager"
  name_prefix   = "terraform"
  secret_string = jsonencode(local.db_creds)

  enable_rotation                 = true
  lambda_rotation_arn             = data.aws_lambda_function.rotation_lambda.arn
  rotate_automatically_after_days = var.password_rotation_interval

  tags = {
    Name           = "${var.project_name}-pg-db-secret"
    DatabaseEngine = "PostgreSQL"
    ProjectName    = var.project_name
  }
}

resource "aws_serverlessapplicationrepository_cloudformation_stack" "postgres-rotator" {
  name           = "${var.project_name}-pg-rotator"
  application_id = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSPostgreSQLRotationSingleUser"
  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_RESOURCE_POLICY",
  ]
  parameters = {
    functionName = "${var.project_name}-DbSecretRotationLambda"
    endpoint     = "https://secretsmanager.${var.region}.amazonaws.com"
  }
  tags = {
    Name         = "${var.project_name}-pg-rotator"
    functionName = "${var.project_name}-DbSecretRotationLambda"
    ProjectName  = var.project_name
  }
}

data "aws_lambda_function" "rotation_lambda" {
  function_name = aws_serverlessapplicationrepository_cloudformation_stack.postgres-rotator.tags_all["functionName"]
}
