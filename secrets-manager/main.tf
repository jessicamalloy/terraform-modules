resource "aws_secretsmanager_secret" "secret" {
  count = var.create_secret ? 1 : 0

  name                    = var.name
  name_prefix             = var.name == null ? format("%s-", var.name_prefix) : null
  description             = var.description
  policy                  = var.policy
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window_in_days

  tags = var.tags
}

resource "aws_secretsmanager_secret_rotation" "rotation" {
  count = (var.create_secret && var.enable_rotation) ? 1 : 0

  secret_id           = aws_secretsmanager_secret.secret[0].id
  rotation_lambda_arn = var.lambda_rotation_arn

  rotation_rules {
    automatically_after_days = var.rotate_automatically_after_days
  }

  depends_on = [aws_secretsmanager_secret.secret]
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  count = var.create_secret ? 1 : 0

  secret_id     = aws_secretsmanager_secret.secret[0].id
  secret_string = var.secret_string
  secret_binary = var.secret_binary

  depends_on = [aws_secretsmanager_secret.secret]
}
