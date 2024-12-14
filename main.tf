#s3

variable "s3_bucket_name" {
  description = "choonyeess3.sctp-sandbox.com"
  type        = string
}


resource "aws_s3_bucket" "static_bucket" {
 bucket = "choonyeess3.sctp-sandbox.com"
 force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "enable_public_access" {}

resource "aws_s3_bucket_policy" "allow_public_access" {}

resource "aws_s3_bucket_website_configuration" "website" {}

data "aws_route53_zone" "sctp_zone" {
 name = "sctp-sandbox.com"
}

resource "aws_route53_record" "www" {
 zone_id = data.aws_route53_zone.sctp_zone.zone_id
 name = "choonyeess3" # Bucket prefix before sctp-sandbox.com
 type = "A"

 alias {
   name = aws_s3_bucket_website_configuration.website.website_domain
   zone_id = aws_s3_bucket.static_bucket.hosted_zone_id
   evaluate_target_health = true
 }


#iam policy
data "aws_iam_policy_document" "static_bucket" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::choonyeess3.sctp-sandbox.com",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "",
        "home/",
        "home/&{aws:username}/",
      ]
    }
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/home/&{aws:username}",
      "arn:aws:s3:::${var.s3_bucket_name}/home/&{aws:username}/*",
    ]
  }
}

resource "aws_iam_policy" "example" {
  name   = "example_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.example.json
}