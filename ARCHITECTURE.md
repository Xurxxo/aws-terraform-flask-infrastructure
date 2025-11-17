# Infrastructure Architecture

## Static Website Hosting on AWS

### Components
1. **S3 Bucket**: Static website hosting (HTML, CSS, JS, images)
2. **CloudFront**: Global CDN distribution with HTTPS
3. **Route 53**: Custom domain DNS management
4. **ACM**: Free SSL/TLS certificate
5. **CloudWatch**: Monitoring, logging, and alarms

### Security Features (All Free Tier)
- **AWS Shield Standard**: DDoS protection (automatic)
- **Security Headers**: CSP, HSTS, X-Frame-Options via CloudFront
- **Private S3 Bucket**: Only accessible through CloudFront
- **HTTPS Everywhere**: Free certificate with auto-renewal
- **CloudWatch Alarms**: Monitor for traffic anomalies

### Observability
- **Access Logs**: Track all requests
- **CloudWatch Metrics**: Monitor traffic, errors, latency
- **Custom Dashboards**: Visualize key metrics
- **Alarms**: Email notifications for issues

### Cost Breakdown (AWS Free Tier)
- **S3**: Free tier includes 5GB storage, 20k GET requests/month
- **CloudFront**: Free tier includes 1TB data transfer/year
- **Route 53**: $0.50/month (hosted zone)
- **ACM**: Free
- **Shield Standard**: Free (included)
- **CloudWatch**: Free tier includes 10 alarms, basic monitoring

**Estimated Total: ~$0.50/month + domain registration**

### Budget Protection
- AWS Budget configured with $20/month limit
- Alerts at 50%, 80%, and 100% thresholds
- Automatic email notifications