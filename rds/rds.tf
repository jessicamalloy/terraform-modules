resource "aws_db_subnet_group" "subnet_group" {
  subnet_ids = var.vpc_public_subnets

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    ProjectName = var.project_name
  }
}

resource "aws_security_group" "db_security_group" {
  description = "Enable SSH access and HTTPS access on the inbound port"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.database_port
    to_port     = var.database_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-postgres-db-security-group"
    ProjectName = var.project_name
  }
}

resource "aws_db_instance" "main" {
  snapshot_identifier         = var.snapshot_identifier
  allocated_storage           = var.allocated_storage
  engine                      = var.database_engine
  engine_version              = var.database_engine_version
  parameter_group_name        = var.database_parameter_group_name
  instance_class              = var.database_instance_class
  db_name                     = var.database_name
  username                    = local.db_creds.username
  password                    = local.db_creds.password
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  port                        = var.database_port
  storage_type                = var.storage_type
  iops                        = var.database_iops
  backup_retention_period     = var.backup_retention_period
  multi_az                    = var.multi_az
  db_subnet_group_name        = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids      = [aws_security_group.db_security_group.id]
  publicly_accessible         = var.publicly_accessible
  storage_encrypted           = var.storage_encrypted
  skip_final_snapshot         = var.skip_final_snapshot
  apply_immediately           = var.database_apply_immediately
  allow_major_version_upgrade = var.database_allow_major_version_upgrade
  lifecycle {
    create_before_destroy = true
  }
}

/*
 * Terraform does not support secret attachment to RDS instance.  This attachement
 * is important to keep secret and host information in sync when loading from snapshot.
 */
resource "aws_cloudformation_stack" "secret_attachment" {
  name          = "${var.project_name}-DBInstanceSecretAttachment"
  template_body = <<STACK

Resources:
  DBInstanceSecretAttachment:
    Type: AWS::SecretsManager::SecretTargetAttachment
    Properties:
      SecretId: ${module.secrets_manager.secret_id}
      TargetId: ${aws_db_instance.main.id}
      TargetType: AWS::RDS::DBInstance

  STACK
}
