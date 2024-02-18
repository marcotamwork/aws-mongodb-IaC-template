resource "aws_s3_bucket" "s3" {
  bucket = var.cluster_name
}


resource "aws_s3_bucket_public_access_block" "s3" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3" {
  bucket = aws_s3_bucket.s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3,
    aws_s3_bucket_public_access_block.s3,
  ]

  bucket = aws_s3_bucket.s3.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

