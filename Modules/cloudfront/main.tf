resource "aws_cloudfront_distribution" "this" {
  enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-${var.domain_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  origin {
    domain_name = var.domain_name
    origin_id   = "S3-${var.domain_name}"

    s3_origin_config {
      origin_access_identity = var.origin_access_identity
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.ssl_support_method
    minimum_protocol_version       = var.minimum_protocol_version
  }

  price_class         = var.price_class
  http_version        = var.http_versions
  default_root_object = "index.html"
  aliases             = var.aliases
  
  tags = {
    Name = "CloudFront Distribution"
  }
}
