resource "aws_lb" "_" {
  name               = "tendenci-lb-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "_" {
  name        = "tendenci-${var.env}"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb._.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb._.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate._lb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group._.arn
  }
}

resource "aws_lb_listener_rule" "files" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100
  action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code = 403
    }
  }
  condition {
    path_pattern {
      values = [
        "/media/forms/*",
        "/media/corporate_memberships/*",
        "/media/files/files/*"
      ]
    }
  }
}
