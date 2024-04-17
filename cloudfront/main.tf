data "terraform_remote_state" "alb" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "elb/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "acm" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "acm/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

#creating Cloudfront distribution :
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  aliases             =  ["cats.gguduck.com"]
  origin {
    domain_name = data.terraform_remote_state.alb.outputs.elb-dns
    origin_id   = data.terraform_remote_state.alb.outputs.elb-dns
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = data.terraform_remote_state.alb.outputs.elb-dns
    viewer_protocol_policy = "redirect-to-https"
   
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }
  viewer_certificate {
    acm_certificate_arn      = data.terraform_remote_state.acm.outputs.acm_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

