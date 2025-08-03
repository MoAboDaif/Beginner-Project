output "static_website_url" {
  value = "http://${aws_s3_bucket.static_website.bucket_regional_domain_name}"
}