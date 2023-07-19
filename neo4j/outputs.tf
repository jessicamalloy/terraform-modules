output "db_secret_id" {
    value = module.secrets_manager.secret_id
}

output "neo4j_webadmin" {
  description = "This is the address of your Neo4j server web administration console."
  value       = "https://${local.neo4j_domain}:${var.https_port}/browser"
}

output "neo4j_public_ip" {
  description = "The public IP address assigned to the EC2 instance."
  value       = aws_instance.neo4j.public_ip
}

output "neo4j_bolt_port" {
  description = "The bolt port number."
  value       = var.bolt_port
}
