# S3 Bucket (Private)
resource "aws_s3_bucket" "static_website" {
  bucket        = "moabodaif-static-website-bucket-${terraform.workspace}"
  force_destroy = true

  tags = {
    Name = "My Static Website Bucket"
  }
}

# Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "static_website" {
  name                              = "${aws_s3_bucket.static_website.bucket}-${terraform.workspace}"
  description                       = "OAC for secure S3 access via CloudFront"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Bucket policy allowing only CloudFront access via OAC
data "aws_iam_policy_document" "cloudfront_oac_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.static_website.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.static_website_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "static_website" {
  bucket = aws_s3_bucket.static_website.id
  policy = data.aws_iam_policy_document.cloudfront_oac_policy.json
}

# CloudFront Distribution
locals {
  s3_origin_id = "S3Origin-${terraform.workspace}"
}

resource "aws_cloudfront_distribution" "static_website_distribution" {
  origin {
    domain_name              = aws_s3_bucket.static_website.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.static_website.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Secure static website via CloudFront + S3"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 300
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = terraform.workspace
  }
}
