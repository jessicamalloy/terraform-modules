data "aws_partition" "current" {}

data "aws_route53_zone" "primary" {
  name         = "${var.domain_name}"
}

resource "aws_acm_certificate" "cert" {
  domain_name = "${var.domain_name}"
  // either certificate authority arn OR validation_method must be provided, but not both
  validation_method         = var.use_certificate_authority ? null : "DNS"
  certificate_authority_arn = var.use_certificate_authority ? var.certificate_authority_arn : null
  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "r53_record" {
  zone_id         =  data.aws_route53_zone.primary.zone_id
  name            = "${var.project_name}.${var.domain_name}"
  allow_overwrite = true
  type            = "A"

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}
