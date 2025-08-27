# DNS Records
# Creates an alias record pointing the application domain to the ALB
resource "aws_route53_record" "app_domain_alias" {
  zone_id = var.hosted_zone_id
  name    = var.app_domain
  type    = "A"

  alias {
    name    = aws_lb.alb.dns_name
    zone_id = aws_lb.alb.zone_id
    # Set to true to enable health checks for the ALB target
    # This helps Route53 route traffic away from unhealthy ALB targets
    evaluate_target_health = true
  }

  # Allows Terraform to overwrite existing records with the same name
  allow_overwrite = true
}
