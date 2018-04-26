#Create a cloudfront net for serving static web content
resource "aws_cloudfront_origin_access_identity" "cfAccessID" {
    comment = "This ID is to restrict the S3 access to cloud front user"
}

resource "aws_cloudfront_distribution" "cfDistribution" {
    aliases = ["cfs3.anilkasu.co.in","www.cfs3.anilkasu.co.in"]
    comment = "Cloudfron net for bucket website"

    default_cache_behavior {
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]

      forwarded_values {
        cookies {
          forward = "none"
        }
        query_string = false
      }

      #path_pattern = "*"
      target_origin_id = "s3-anilkasu-tfstaticweb" #"${aws_s3_bucket.bucket4web.id}"
      viewer_protocol_policy = "redirect-to-https"
    }

    price_class = "PriceClass_All"

    logging_config {
      bucket = "${aws_s3_bucket.bucket4logs.bucket_domain_name}"
      prefix = "cfn"
      include_cookies = false
    }

    origin {
      domain_name = "${aws_s3_bucket.bucket4web.bucket_domain_name}"
      origin_id = "s3-anilkasu-tfstaticweb"

      s3_origin_config {
        origin_access_identity = "${aws_cloudfront_origin_access_identity.cfAccessID.cloudfront_access_identity_path}"
      }
    }

    viewer_certificate {
      cloudfront_default_certificate = true
    }

    enabled = true
    is_ipv6_enabled = false
    default_root_object = "index.html"

    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }

    http_version = "http2"

    tags {
      Name = "S3-CloudFront"
    }
}
