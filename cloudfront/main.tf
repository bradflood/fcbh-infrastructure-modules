terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  required_version = ">= 0.13"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

module "cloudfront_s3_cdn" {
  source    = "git::https://github.com/cloudposse/terraform-aws-cloudfront-s3-cdn.git?ref=tags/0.32.0"
  namespace = var.namespace
  stage     = var.stage
  name      = var.name

  acm_certificate_arn      = var.acm_certificate_arn
  parent_zone_name         = var.parent_zone_name
  aliases                  = var.aliases
  allowed_methods          = ["GET", "HEAD", "OPTIONS"]
  cached_methods           = ["GET", "HEAD", "OPTIONS"]
  compress                 = true
  cors_allowed_headers     = ["Authorization"]
  cors_allowed_methods     = ["GET"]
  cors_allowed_origins     = var.cors_allowed_origins
  cors_expose_headers      = ["ETag"]
  default_ttl              = var.default_ttl
  ipv6_enabled             = var.ipv6_enabled
  log_prefix               = var.log_prefix
  minimum_protocol_version = var.minimum_protocol_version
  origin_force_destroy     = var.origin_force_destroy
  origin_bucket            = var.origin_bucket
  price_class              = var.price_class
  trusted_signers          = ["self"]
  viewer_protocol_policy   = "allow-all"
}

resource "aws_s3_bucket_object" "index" {
  bucket       = module.cloudfront_s3_cdn.s3_bucket
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
  etag         = md5(file("${path.module}/index.html"))
}

resource "aws_s3_bucket_public_access_block" "cloudfront-origin" {
  bucket = module.cloudfront_s3_cdn.s3_bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
