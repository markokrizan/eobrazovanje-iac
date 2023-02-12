data "aws_route53_zone" "main" {
  name = var.DOMAIN
}

resource "aws_acm_certificate" "cert" {
  domain_name       = format("*.%s", var.DOMAIN)
  validation_method = "DNS"

  tags = {
    Environment = "production"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}

output "zone_id" {
  value = data.aws_route53_zone.main.zone_id
}

output "domain" {
  value = var.DOMAIN
}
