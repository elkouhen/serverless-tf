resource "aws_s3_bucket" "bucket" {
  bucket = "bucket-gui-${var.env}"
}

data "aws_iam_policy_document" "bucket" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.bucket.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket.json
}

resource "aws_s3_bucket" "logs" {
  bucket = "bucket-gui-logs-${var.env}"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

locals {
  s3_origin_id = "s3-origin"
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "Some comment"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name

    origin_id = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "bucket-gui-logs-${var.env}.s3.amazonaws.com"
  }

  aliases = ["helloworld.sbx.aws.ippon.fr"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["FR"]
    }
  }


  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }
}

data "aws_route53_zone" "hosted_zone" {
  name = "sbx.aws.ippon.fr"
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}

locals {
  domains = tolist(aws_acm_certificate.cert.domain_validation_options)

  index = index(local.domains.*.domain_name, "helloworld.sbx.aws.ippon.fr")
}

resource "aws_route53_record" "cert" {

  allow_overwrite = true

  name    = tolist(aws_acm_certificate.cert.domain_validation_options)[local.index].resource_record_name
  type    = tolist(aws_acm_certificate.cert.domain_validation_options)[local.index].resource_record_type
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  records = [tolist(aws_acm_certificate.cert.domain_validation_options)[local.index].resource_record_value]
  ttl     = 60
}


resource "aws_acm_certificate" "cert" {
  provider          = aws.acm_provider
  domain_name       = "helloworld.sbx.aws.ippon.fr"
  validation_method = "DNS"

  # subject_alternative_names = ["helloworld.sbx.aws.ippon.fr", aws_cloudfront_distribution.s3_distribution.domain_name]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert" {

  provider = aws.acm_provider

  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert.fqdn]
}


resource "aws_route53_record" "app_domain" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "helloworld.sbx.aws.ippon.fr"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
