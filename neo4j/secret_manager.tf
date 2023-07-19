module "secrets_manager" {
    source = "github.com/AllenInstitute/platform-terraform-modules/secrets-manager"

    name_prefix   = "${var.project_name}-neo4j-${var.neo4j_edition}"
    description = "${var.project_name} Neo4j graph database credentials."
    secret_string = jsonencode(local.db_creds)

    tags = {
        Name = "${var.project_name}-neo4j-secret"
        Edition = var.neo4j_edition
        Neo4jVersion = var.neo4j_version
        ProjectName = var.project_name
    }
}

module "neo4j_ec2_ssh" {
  source = "github.com/AllenInstitute/platform-terraform-modules/secrets-manager"

  name_prefix = "${var.project_name}-neo4j-ec2-key-pair"
  description = "${var.project_name} Neo4j EC2 instance SSH key-pair info."

  # adds Neo4J EC2 instance key-pair for SSHing into instance
  secret_string = tls_private_key.neo4j.private_key_pem

  tags = {
    Name            = aws_key_pair.neo4j_key_pair.id
    Edition         = var.neo4j_edition
    Neo4jVersion    = var.neo4j_version
    ProjectName     = var.project_name
  }
}
