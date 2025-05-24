resource "aws_cloudfront_origin_access_identity" "frontend" {}

resource "aws_cloudfront_distribution" "frontend" {
  aliases = [ var.domain ]
  enabled = true

  default_root_object = "index.html"
  custom_error_response {
    error_code = 403
    response_code = 200
    response_page_path = "/"
  }
  custom_error_response {
    error_code = 404
    response_code = 200
    response_page_path = "/"
  }

  origin {
    origin_id = aws_s3_bucket.frontend.id
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id = aws_s3_bucket.frontend.id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods = [ "GET", "HEAD", "OPTIONS" ]
    cached_methods = [ "GET", "HEAD", "OPTIONS" ]

    // FIXME: 何もキャッシュしない設定になっているので注意
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" // CachingDisabled
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = aws_acm_certificate.acm.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  is_ipv6_enabled = true
  wait_for_deployment = false
}
