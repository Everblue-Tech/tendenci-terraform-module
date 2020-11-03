resource "aws_wafv2_web_acl" "cf" {
  name        = "tendenci-${var.env}"
  scope       = "CLOUDFRONT"
  default_action {
    allow {}
  }
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 0
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        excluded_rule {
          name = "NoUserAgent_HEADER"
        }
        excluded_rule {
          name = "SizeRestrictions_BODY"
        }
        excluded_rule {
          name = "CrossSiteScripting_BODY"
        }
        excluded_rule {
          name = "GenericRFI_BODY"
        }
      }
    }
    override_action {
        none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 1
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    override_action {
        none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "tendenci-${var.env}"
      sampled_requests_enabled   = true
    }
  provider = aws.commercial
}