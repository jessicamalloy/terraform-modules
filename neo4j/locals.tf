locals {
  labels = {
    neo4j_ec2_cw_agent       = "amazon-cloudwatch-agent.log"
    neo4j_nightly_backup_log = "neo4j-nightly-backup.log"
    neo4j_ec2_setup          = "neo4j-setup.log"
    neo4j_db_log             = "neo4j.log"
    neo4j_db_debug_log       = "debug.log"
  }
}

locals {
  n10s_plugin_version = "4.4.0.0"
  apoc_plugin_version = "4.4.0.3"
  neo4j_domain = "neo4j-${var.project_name}.${var.domain_name}"
  password = random_password.password.result
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*"
}

locals {
    db_creds = merge (
      {
        username  = "neo4j"
        password  = local.password
        dbname    = "neo4j"
        host      = aws_instance.neo4j.public_ip
        port      = var.bolt_port
      },
      var.project_secret_values
    )
}
