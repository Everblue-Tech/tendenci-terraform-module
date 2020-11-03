resource "aws_security_group" "tendenci" {
  name        = "tendenci_ecs-${var.env}"
  description = "Tendenci ECS Containers"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "lb" {
  name        = "tendenci_lb-${var.env}"
  description = "Tendenci Application Load Balancer"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "efs" {
  name        = "tendenci_efs-${var.env}"
  description = "Tendenci EFS"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "elasticache" {
  name        = "tendenci_elasticache-${var.env}"
  description = "Tendenci Elastiache"
  vpc_id      = var.vpc_id
}

# Load balancer rules
resource "aws_security_group_rule" "http" {
  type                     = "ingress"
  description              = "Inbound from Internet"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https" {
  type                     = "ingress"
  description              = "Inbound from Internet"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb_to_tendenci" {
  type                     = "egress"
  description              = "outbound to tendenci"
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb.id
  source_security_group_id = aws_security_group.tendenci.id
}

#EFS Rules
resource "aws_security_group_rule" "efs_from_tendenci" {
  type                     = "ingress"
  description              = "Tendenci to EFS"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.tendenci.id
}

#Tendenci rules
resource "aws_security_group_rule" "tendenci_from_lb" {
  type                     = "ingress"
  description              = "inbound to tendenci"
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.tendenci.id
  source_security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "tendenci_to_db" {
  type                     = "egress"
  description              = "outbound to db"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.tendenci.id
  source_security_group_id = var.database_security_group
}

resource "aws_security_group_rule" "tendenci_to_ec" {
  type                     = "egress"
  description              = "outbound to ec"
  from_port                = 11211
  to_port                  = 11211
  protocol                 = "tcp"
  security_group_id        = aws_security_group.tendenci.id
  source_security_group_id = aws_security_group.elasticache.id
}

resource "aws_security_group_rule" "tendenci_to_efs" {
  type                     = "egress"
  description              = "Outbound to EFS"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.tendenci.id
  source_security_group_id = aws_security_group.efs.id
  }

resource "aws_security_group_rule" "tendenci_https" {
  type              = "egress"
  description       = "Outbound to HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.tendenci.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "tendenci_http" {
  type              = "egress"
  description       = "Outbound to HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.tendenci.id
  cidr_blocks       = ["0.0.0.0/0"]
}

  #elasticache rules
resource "aws_security_group_rule" "ec_from_tendenci" {
  type                     = "ingress"
  description              = "from tendenci"
  from_port                = 11211
  to_port                  = 11211
  protocol                 = "tcp"
  security_group_id        = aws_security_group.elasticache.id
  source_security_group_id = aws_security_group.tendenci.id
}

#database rules
resource "aws_security_group_rule" "db_from_tendenci" {
  type                     = "ingress"
  description              = "from tendenci"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.database_security_group
  source_security_group_id = aws_security_group.tendenci.id
}