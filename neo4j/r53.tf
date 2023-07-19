data "aws_route53_zone" "primary" {
  name = var.domain_name
}

resource "aws_route53_record" "r53_record" {
  zone_id         = data.aws_route53_zone.primary.zone_id
  name            = local.neo4j_domain
  allow_overwrite = true
  type            = "CNAME"
  ttl             = "30"
  records         = [aws_instance.neo4j.public_dns]
}
