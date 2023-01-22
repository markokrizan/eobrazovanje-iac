resource "aws_s3_bucket" "site" {
  bucket = "${var.BUCKET_NAME}"
  acl = "public-read"

  policy = <<EOF
    {
      "Version":"2008-10-17",
      "Statement":[{
        "Sid":"AllowPublicRead",
        "Effect":"Allow",
        "Principal": {"AWS": "*"},
        "Action":["s3:GetObject"],
        "Resource":["arn:aws:s3:::${var.BUCKET_NAME}/*"]
      }]
    }
  EOF

  website {
      index_document = "index.html"
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    origin_id   = "${var.BUCKET_NAME}"
    domain_name = "${var.BUCKET_NAME}.s3.amazonaws.com"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.BUCKET_NAME}"

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
    cloudfront_default_certificate = true
  }
}

// check this if redirect still happening
// https://stackoverflow.com/questions/38735306/aws-cloudfront-redirecting-to-s3-bucket
output "cdn_domain" {
  value = "${aws_cloudfront_distribution.cdn.domain_name}"
}
