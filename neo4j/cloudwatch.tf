resource "aws_cloudwatch_log_group" "neo4j_ec2_cw_agent" {
  name              = "/aws/ec2/${var.project_name}/neo4j/${local.labels.neo4j_ec2_cw_agent}"
  retention_in_days = var.cloudwatch_retention_days
}

resource "aws_cloudwatch_log_group" "neo4j_nightly_backup" {
  name              = "/aws/ec2/${var.project_name}/neo4j/${local.labels.neo4j_nightly_backup_log}"
  retention_in_days = var.cloudwatch_retention_days
}

resource "aws_cloudwatch_log_group" "neo4j_ec2_setup" {
  name              = "/aws/ec2/${var.project_name}/neo4j/${local.labels.neo4j_ec2_setup}"
  retention_in_days = var.cloudwatch_retention_days
}

resource "aws_cloudwatch_log_group" "neo4j_db_log" {
  name              = "/aws/ec2/${var.project_name}/neo4j/${local.labels.neo4j_db_log}"
  retention_in_days = var.cloudwatch_retention_days
}

resource "aws_cloudwatch_log_group" "neo4j_db_debug_log" {
  name              = "/aws/ec2/${var.project_name}/neo4j/${local.labels.neo4j_db_debug_log}"
  retention_in_days = var.cloudwatch_retention_days
}
