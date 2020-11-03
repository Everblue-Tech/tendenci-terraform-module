resource "aws_acm_certificate" "_lb" {
  domain_name       = "lb.${var.site_url}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "_lb" {
  for_each = {
    for dvo in aws_acm_certificate._lb.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
  provider = aws.commercial
}

resource "aws_acm_certificate_validation" "_lb" {
  certificate_arn         = aws_acm_certificate._lb.arn
  validation_record_fqdns = [for record in aws_route53_record._lb : record.fqdn]
}

resource "aws_acm_certificate" "_" {
  domain_name       = var.site_url
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  provider = aws.commercial
}

resource "aws_route53_record" "_" {
  for_each = {
    for dvo in aws_acm_certificate._.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
  provider = aws.commercial
}

resource "aws_acm_certificate_validation" "_" {
  certificate_arn         = aws_acm_certificate._.arn
  validation_record_fqdns = [for record in aws_route53_record._ : record.fqdn]
  provider = aws.commercial
}