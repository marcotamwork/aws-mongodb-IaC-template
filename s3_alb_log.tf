resource "aws_s3_bucket" "s3_alb" {
  bucket = "${var.cluster_name}-alb-log"
}


resource "aws_s3_bucket_public_access_block" "s3_alb" {
  bucket = aws_s3_bucket.s3_alb.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_alb" {
  bucket = aws_s3_bucket.s3_alb.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3_alb" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_alb,
    aws_s3_bucket_public_access_block.s3_alb,
  ]

  bucket = aws_s3_bucket.s3_alb.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "s3_alb_policy" {
  bucket = aws_s3_bucket.s3_alb.id
  policy = data.aws_iam_policy_document.s3_alb_policy.json
}

