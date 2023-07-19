data "template_file" "neo4j_cw_config" {
  template = file("${path.module}/templates/configurations/neo4j-ec2-cloudwatch.json.tmpl")

  vars = {
    project_name         = var.project_name
    ec2_cw_agent         = local.labels.neo4j_ec2_cw_agent
    neo4j_nightly_backup = local.labels.neo4j_nightly_backup_log
    neo4j_setup          = local.labels.neo4j_ec2_setup
    neo4j_logs           = local.labels.neo4j_db_log
    neo4j_debug_logs     = local.labels.neo4j_db_debug_log
  }
}

data "template_file" "neo4j_init" {
  template = file("${path.module}/templates/provisioners/neo4j_init.yml.tmpl")

  vars = {
    neo4j_tools_content  = filebase64("${path.module}/templates/provisioners/neo4j_tools.sh.tmpl")
    s3_backup            = aws_s3_bucket.backup_bucket.id
    neo4j_password       = local.password
    n10s_plugin_version  = local.n10s_plugin_version
    apoc_plugin_version  = local.apoc_plugin_version
    neo4j_ec2_cw_config  = base64encode(data.template_file.neo4j_cw_config.rendered)
    neo4j_nightly_backup = local.labels.neo4j_nightly_backup_log
    neo4j_setup          = local.labels.neo4j_ec2_setup
    neo4j_domain         = local.neo4j_domain
    base_domain          = var.domain_name
    version              = var.neo4j_version
  }
}

data "template_cloudinit_config" "init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "neo4j_init.yml"
    content_type = "text/cloud-config"
    content      = data.template_file.neo4j_init.rendered
  }
}

resource "aws_instance" "neo4j" {
  ami           = var.ami
  instance_type = var.neo4j_instance_type

  disable_api_termination = false

  monitoring = true

  key_name               = aws_key_pair.neo4j_key_pair.key_name
  subnet_id              = var.vpc_public_subnets[0]
  vpc_security_group_ids = [aws_security_group.db_security_group.id]

  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.neo4j_instance_profile.name

  user_data_base64 = data.template_cloudinit_config.init.rendered

  ebs_optimized = true

  root_block_device {
    volume_type = var.neo4j_volume_type
    volume_size = var.neo4j_volume_size_gb
  }

  tags = {
    Name                            = "neo4j-${var.neo4j_edition}"
    ProjectName                     = var.project_name
    Engine                          = "Neo4j"
    Edition                         = var.neo4j_edition
    neo4j_mode                      = "SINGLE"
    dbms_mode                       = "SINGLE"
    dbms_default_advertised_address = local.neo4j_domain
  }
}

resource "aws_ec2_tag" "ebs_tag" {
  resource_id = aws_instance.neo4j.root_block_device.0.volume_id
  key         = "Name"
  value       = "Root Volume ${aws_instance.neo4j.id}"
}
