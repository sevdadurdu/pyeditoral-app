resource "aws_security_group" "load_balancer" {
  name        = "load-balancer-security-group"
  description = "Controls access to the ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["34.207.51.8/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["34.207.51.8/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "this" {
  name               = "${local.ecs_cluster_name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_alb_target_group" "default_target_group" {
  name        = "${local.ecs_cluster_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = "/ping/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }
}

resource "aws_alb_listener" "ecs_alb_http_listener" {
  load_balancer_arn = aws_lb.this.id
  port              = "80"
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

resource "aws_alb_listener" "ecs_alb_https_listener" {
  load_balancer_arn = aws_lb.this.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.this.arn
  depends_on        = [aws_alb_target_group.default_target_group]

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "NOT FOUND"
      status_code  = "404"
    }
  }
}

resource "aws_acm_certificate" "this" {
  domain_name       = "*.cloud34742.site"
  validation_method = "DNS"

  tags = local.tags
}

resource "aws_route53_record" "cert" {
  zone_id = local.zone_id
  name    = "_b51ead5080fafad05031a0bbb659d999.cloud34742.site."
  type    = "CNAME"
  ttl     = 300
  records = ["_e5987f08ced5174d4ce2c56d32a086a0.mhbtsbpdnt.acm-validations.aws."]
}