resource "aws_cloudfront_distribution" "_" {
  origin {
    domain_name = "lb.${var.site_url}"
    origin_id = "tendenci"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["SSLv3", "TLSv1.2"]
    }
  }
  enabled = true
  is_ipv6_enabled = true
  aliases = [var.site_url]
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "tendenci"
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["*"]
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate._.arn
    ssl_support_method = "sni-only"
  }
  web_acl_id = aws_wafv2_web_acl.cf.arn
  provider = aws.commercial
}

resource "aws_route53_record" "cf" {
  zone_id = var.route53_zone_id
  name    = var.site_url
  type    = "A"
  provider = aws.commercial
  alias {
    name                   = aws_cloudfront_distribution._.domain_name
    zone_id                = aws_cloudfront_distribution._.hosted_zone_id
    evaluate_target_health = true
  }
}