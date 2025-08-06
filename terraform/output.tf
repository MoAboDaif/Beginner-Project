# output "static_website_url" {
#   value = "http://${aws_s3_bucket_website_configuration.static_website.website_endpoint}"
# }

output "s3_bucket_name" {
  value = aws_s3_bucket.static_website.bucket
}

output "cloudfront_distribution" {
  value = "https://${aws_cloudfront_distribution.static_website_distribution.domain_name}"
}