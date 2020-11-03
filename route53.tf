resource "aws_route53_record" "lb" {
  zone_id = var.route53_zone_id
  name    = "lb.${var.site_url}"
  type    = "A"
  alias {
    name                   = aws_lb._.dns_name
    zone_id                = aws_lb._.zone_id
    evaluate_target_health = true
  }
  provider = aws.commercial
}