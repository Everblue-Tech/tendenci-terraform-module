data "aws_region" "ses" {
  provider = aws.ses
}

# Domain Identity
resource "aws_ses_domain_identity" "_" {
  domain = var.site_url
  provider = aws.ses
}

#Create verification record
resource "aws_route53_record" "_ses" {
  zone_id = var.route53_zone_id
  name    = "_amazonses.${aws_ses_domain_identity._.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity._.verification_token]
  provider = aws.commercial
}

# Verify DNS Record
resource "aws_ses_domain_identity_verification" "_" {
  domain = aws_ses_domain_identity._.id
  provider = aws.ses
  depends_on = [aws_route53_record._ses]
}

# Mail From Domain
resource "aws_ses_domain_mail_from" "_" {
  domain           = aws_ses_domain_identity._.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity._.domain}"
  provider = aws.ses
}

# Route53 MX record
resource "aws_route53_record" "_mx" {
  zone_id = var.route53_zone_id
  name    = aws_ses_domain_mail_from._.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${data.aws_region.current.name}.amazonses.com"]
  provider = aws.commercial
}

# Route53 TXT record for SPF
resource "aws_route53_record" "_spf" {
  zone_id = var.route53_zone_id
  name    = aws_ses_domain_mail_from._.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
  provider = aws.commercial
}

#Create SMTP Credentials
resource "aws_iam_user" "_" {
  name = "tendenci_smtp_user_${var.env}"
}

resource "aws_iam_access_key" "_" {
  user = aws_iam_user._.name
}

resource "aws_iam_user_policy" "_" {
  name = "SENDMAIL"
  user = aws_iam_user._.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action":[
        "ses:SendRawEmail",
        "ses:SendEmail",
        "ses:GetSendQuota"
      ],
      "Resource":"*"
    }
  ]
}
EOF
}

#Create Identity Policy
data "aws_iam_policy_document" "_" {
  statement {
    actions   = ["SES:SendEmail", "SES:SendRawEmail"]
    resources = [aws_ses_domain_identity._.arn]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

resource "aws_ses_identity_policy" "_" {
  identity = aws_ses_domain_identity._.arn
  name     = "smtp_user_${var.env}"
  policy   = data.aws_iam_policy_document._.json
  provider = aws.ses
}