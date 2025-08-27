# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "app-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_tf_sg.id]
  subnets            = slice(values(aws_subnet.public)[*].id, 0, 2)

  tags = {
    Name = "app-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # Health check configuration for application monitoring
  health_check {
    path                = "/up"
    matcher             = "200"
    interval            = 100
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 3
  }

  tags = {
    Name = "app-tg"
  }
}

# Target Group Attachment
resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.app.id
  port             = 80
}

# HTTP Listener
# Redirects all HTTP traffic to HTTPS for security
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
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

# ACM Certificate Data Source
data "aws_acm_certificate" "rails_movie_api" {
  domain      = var.app_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = data.aws_acm_certificate.rails_movie_api.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
