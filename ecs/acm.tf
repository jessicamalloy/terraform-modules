data "aws_route53_zone" "primary" {
  name = var.domain_name
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.project_name}.${var.domain_name}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "r53_record" {  
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${var.project_name}.${var.domain_name}"
  allow_overwrite = true
  type    = "A"

  alias {
      name = aws_lb.lb.dns_name
      zone_id = aws_lb.lb.zone_id
      evaluate_target_health  = true
  }
}
