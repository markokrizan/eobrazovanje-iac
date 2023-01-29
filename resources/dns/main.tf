resource "aws_route53_zone" "main" {
  name = "ftn-edu-app.com"

  tags = {
    Environment = "production"
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "*.ftn-edu-app.com"
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
  value = aws_route53_zone.main.zone_id
}
