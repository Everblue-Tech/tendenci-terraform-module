resource "random_password" "secret_key" {
  length = 50
  special = true
}

resource "random_password" "settings_key" {
  length = 50
  special = true
}

resource "aws_secretsmanager_secret" "tendenci" {
  name = "tendenci-${var.env}"
}

resource "aws_secretsmanager_secret_version" "tendenci" {
  secret_id     = aws_secretsmanager_secret.tendenci.id
  secret_string = jsonencode(
    map(
    "SECRET_KEY", random_password.secret_key.result,
    "SITE_SETTINGS_KEY", random_password.settings_key.result,
    "db_host", var.db_host,
    "db_password", var.db_password,
    "db_user", var.db_user,
    "db_name", var.db_name,
    "db_port", 5432,
    "cache_host", aws_elasticache_cluster._.cluster_address,
    "T_AWS_SES_REGION_NAME", data.aws_region.ses.name,
    "T_AWS_SES_REGION_ENDPOINT", "email.${data.aws_region.ses.name}.amazonaws.com",
    "T_AWS_SES_ACCESS_KEY_ID", aws_iam_access_key._.id,
    "T_AWS_SES_SECRET_ACCESS_KEY", aws_iam_access_key._.secret,
    "T_EMAIL_BACKEND", "django_ses.SESBackend",
    "T_DEFAULT_FROM_EMAIL", "noreply@${var.site_url}",
    "ALLOWED_HOSTS", var.site_url
    )
  )
}