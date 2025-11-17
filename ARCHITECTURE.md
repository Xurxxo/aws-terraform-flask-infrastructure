# Infrastructure Architecture

## New Architecture: S3 + CloudFront Static Hosting

### Components
1. **S3 Bucket**: Static website hosting
2. **CloudFront**: CDN distribution with HTTPS
3. **Route 53**: Custom domain DNS
4. **ACM**: SSL/TLS certificate
5. **CloudWatch**: Monitoring and alarms

### Security Features (All Free Tier)
- AWS Shield Standard (DDoS protection)
- Security Headers (CSP, HSTS, X-Frame-Options)
- Private S3 bucket (CloudFront-only access)
- HTTPS with ACM certificate
- CloudWatch alarms for anomaly detection

### Cost Breakdown
- S3: Free tier (5GB storage, 20k GET requests/month)
- CloudFront: Free tier (1TB transfer/year)
- Route 53: $0.50/month
- ACM: Free
- Shield Standard: Free
- CloudWatch: Free (basic monitoring)

**Total: ~$0.50/month + domain cost**

### Budget Protection
AWS Budget configured with $20/month hard limit and alerts at 80% threshold.
