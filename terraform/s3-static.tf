# resource "aws_s3_bucket" "backend" {
#   bucket = "moabodaif-terraform-s3-backend"
# }

# resource "aws_dynamodb_table" "backend_lock" {
#   name           = "backend-lock-table"
#   read_capacity  = 5
#   write_capacity = 5
#   hash_key       = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

resource "aws_s3_bucket" "static_website" {
  bucket        = "moabodaif-static-website-bucket-${terraform.workspace}"
  force_destroy = true
  tags = {
    Name = "My Static Website Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "static_website_policy_document" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.static_website.arn}/*",
      aws_s3_bucket.static_website.arn
    ]
    effect = "Allow"
  }
}

resource "aws_s3_bucket_policy" "static_website" {
  bucket = aws_s3_bucket.static_website.id
  policy = data.aws_iam_policy_document.static_website_policy_document.json
}

resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}
