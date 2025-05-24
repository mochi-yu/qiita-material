resource "aws_s3_bucket" "frontend" {
  bucket = var.domain
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.frontend_policy_doc.json
}

data "aws_iam_policy_document" "frontend_policy_doc" {
  statement {
    sid = "AllowCloudFrontServicePrincipal_${var.domain}"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.frontend.iam_arn]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend.arn}/*"]
  }
}
