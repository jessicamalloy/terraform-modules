resource "aws_security_group" "db_security_group" {
  description = "Enable SSH, HTTPS, and Bolt access on the inbound port"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Bolt"
    from_port   = var.bolt_port
    to_port     = var.bolt_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Neo4j HTTPS"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }

  tags = {
    Name = "${var.project_name}-neo4j-security-group"
    ProjectName = var.project_name
  }
}
