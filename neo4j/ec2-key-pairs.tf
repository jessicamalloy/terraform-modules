resource "tls_private_key" "neo4j" {
  algorithm = "RSA"
}

resource "aws_key_pair" "neo4j_key_pair" {
  key_name   = "${var.project_name}-neo4j-key-pair"
  public_key = tls_private_key.neo4j.public_key_openssh

  tags = {
    ProjectName = var.project_name
    Engine      = "Neo4j"
    Edition     = var.neo4j_edition
  }
}
