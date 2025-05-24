resource "aws_acm_certificate" "acm" {
  domain_name = var.domain
  validation_method = "DNS"
  provider = aws.use1
}
