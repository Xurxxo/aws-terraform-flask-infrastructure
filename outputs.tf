output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.website.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.website.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name (your website URL)"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "website_url" {
  description = "Website URL"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for S3 access logs"
  value       = aws_cloudwatch_log_group.s3_access.name
}

output "domain_name" {
  description = "Custom domain name"
  value       = var.domain_name
}

output "custom_domain_url" {
  description = "Custom domain URL (your actual website)"
  value       = "https://${var.domain_name}"
}

output "www_domain_url" {
  description = "WWW domain URL"
  value       = "https://www.${var.domain_name}"
}

output "route53_nameservers" {
  description = "Route 53 nameservers (configured in Namecheap)"
  value       = aws_route53_zone.main.name_servers
}
