module "fargate_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.3.0"

  name        = "${var.project_name}-fargate-security-group"
  description = "Access to the Fargate containers"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = concat(
    local.ingress_with_cidr_blocks,
    var.project_ingress_with_cidr_blocks
  )

  egress_with_cidr_blocks = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = "0.0.0.0/0"
      ipv6_cidr_blocks = "::/0"
    }
  ]

  tags = {
    Name        = "${var.project_name}-fargate-security-group"
    ProjectName = var.project_name
  }
}
