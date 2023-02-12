# https://medium.com/runatlantis/hosting-our-static-site-over-ssl-with-s3-acm-cloudfront-and-terraform-513b799aec0f
variable "domain" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "zone_id" {
  type = string
}

locals {
  app_full_uri = format("app.%s", var.domain)
}

resource "aws_s3_bucket" "site" {
  bucket = local.app_full_uri
  acl = "public-read"

  policy = <<EOF
    {
      "Version":"2008-10-17",
      "Statement":[{
        "Sid":"AllowPublicRead",
        "Effect":"Allow",
        "Principal": {"AWS": "*"},
        "Action":["s3:GetObject"],
        "Resource":["arn:aws:s3:::${local.app_full_uri}/*"]
      }]
    }
  EOF

  website {
      index_document = "index.html"
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  depends_on = [
    aws_s3_bucket.site
  ]

  # region sertifikata ne valja ovde morace globalni posto je cdn globalni, trebace ti novi cert jebemu
  # https://stackoverflow.com/questions/53981403/can-terraform-be-used-simply-to-create-resources-in-different-aws-regions
  # ili zaseban sertifikat
  origin {
    origin_id   = local.app_full_uri
    domain_name = aws_s3_bucket.site.bucket_domain_name
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.app_full_uri
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  aliases = [local.app_full_uri]

  # The cheapest priceclass
  price_class = "PriceClass_100"

  # This is required to be specified even if it's not used.
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method  = "sni-only"
  }

  # Workaround for redirection usually used if the deployed content is a SPA
  # 404 redirects to the index.html which then uses the client side routing to redirect
  # to the appropriate page
  custom_error_response {
    error_code = 404
    response_code = 200
    response_page_path = "/index.html"
  }
}

// This Route53 record will point at our CloudFront distribution.
resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = local.app_full_uri
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}
