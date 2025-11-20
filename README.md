# 🏗️ AWS Terraform Flask Infrastructure

Infrastructure as Code (IaC) for hosting a static website on AWS using Terraform. Powers [xurxo.cloud](https://xurxo.cloud).

## 🌐 Live Site

**URL:** [https://xurxo.cloud]

---

## 📑 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [AWS Resources](#aws-resources)
- [Domain Setup](#domain-setup)
- [Quick Start](#quick-start)
- [Deployment](#deployment)
- [Costs](#costs)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Related Repository](#related-repository)

---

## 🎯 Overview

This Terraform configuration deploys a complete static website infrastructure on AWS:

- **S3** for static file storage
- **CloudFront** for global CDN distribution
- **Route 53** for DNS management
- **ACM** for free SSL/TLS certificates
- **CloudWatch** for monitoring and alarms
- **AWS Budgets** for cost control

See [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed infrastructure documentation.

---

## 📋 Prerequisites

### Required Tools

| Tool | Version | Installation |
|------|---------|--------------|
| Terraform | >= 1.0 | `brew install terraform` |
| AWS CLI | >= 2.0 | `brew install awscli` |
| Git | >= 2.0 | `brew install git` |

### AWS Account Setup

1. **AWS Account** with admin permissions
2. **IAM User** with programmatic access
3. **AWS CLI configured:**
```bash
aws configure
# AWS Access Key ID: [your-key]
# AWS Secret Access Key: [your-secret]
# Default region: eu-central-1
# Default output format: json
```

### Domain (Optional but Recommended)

- Domain purchased from registrar (e.g., Namecheap, GoDaddy)
- Access to DNS settings

---

## 🏛️ AWS Resources

This Terraform configuration creates **16 AWS resources:**

| Resource | Purpose |
|----------|---------|
| `aws_s3_bucket` | Static file storage |
| `aws_s3_bucket_public_access_block` | Block public access |
| `aws_s3_bucket_policy` | CloudFront-only access |
| `aws_cloudfront_origin_access_control` | Secure S3 access |
| `aws_cloudfront_distribution` | Global CDN |
| `aws_cloudfront_response_headers_policy` | Security headers (CSP, HSTS) |
| `aws_cloudfront_function` | URL rewriting |
| `aws_route53_zone` | DNS hosted zone |
| `aws_route53_record` (website) | A record for apex domain |
| `aws_route53_record` (www) | A record for www subdomain |
| `aws_route53_record` (cert_validation) | Certificate validation |
| `aws_acm_certificate` | SSL/TLS certificate |
| `aws_acm_certificate_validation` | Certificate validation |
| `aws_cloudwatch_log_group` | Access logs |
| `aws_cloudwatch_metric_alarm` | High traffic alerts |
| `aws_budgets_budget` | Cost alerts |

---

## 🌐 Domain Setup

### Domain Purchase (Namecheap)

1. **Purchase domain** at [namecheap.com](https://namecheap.com)
   - Domain used: `xurxo.cloud`
   - Cost: ~$2.75/year 

### Connect to AWS Route 53

After running `terraform apply`:

1. **Get Route 53 nameservers:**
```bash
terraform output route53_nameservers
```

2. **Update Namecheap DNS:**
   - Login to Namecheap → Domain List → Manage
   - Nameservers → Custom DNS
   - Add all 4 AWS nameservers
   - Save

3. **Wait for propagation:** 15-48 hours

4. **Verify:**
```bash
dig xurxo.cloud NS
```

---

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/Xurxxo/aws-terraform-flask-infrastructure.git
cd aws-terraform-flask-infrastructure
```

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

**terraform.tfvars:**
```hcl
domain_name       = "xurxo.cloud"
bucket_name       = "flask-cv-static-site"
alert_email       = "your-email@gmail.com"
environment       = "production"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan (Review Changes)

```bash
terraform plan
```

### 5. Apply (Create Resources)

```bash
terraform apply
```

### 6. Update Domain Nameservers

Follow [Domain Setup](#domain-setup) section.

---

## 📦 Deployment

### Initial Deployment

```bash
terraform init
terraform plan
terraform apply
```

### Update Infrastructure

```bash
terraform plan
terraform apply
```

### Deploy Website Content

Website content is managed in [flask-cv-containerized-cicd](https://github.com/Xurxxo/flask-cv-containerized-cicd).

**Manual content upload:**
```bash
aws s3 sync ./dist s3://flask-cv-static-site --delete

aws cloudfront create-invalidation \
  --distribution-id E1UI2ORYQ3SFQO \
  --paths "/*"
```

### Destroy Infrastructure

```bash
terraform destroy
```

---

## 💰 Costs

### Monthly Breakdown

| Service | Free Tier | Your Usage |
|---------|-----------|------------|
| **S3 Storage** | 5GB | ~$0.05 |
| **CloudFront Transfer** | 1TB/year | ~$0.00 |
| **Route 53 Hosted Zone** | - | $0.50 |
| **ACM Certificate** | Free | $0.00 |
| **CloudWatch** | 10 alarms | ~$0.00 |

### Estimated Total

| Scenario | Monthly Cost |
|----------|--------------|
| **Low traffic** (<1k visits) | ~$0.55 |
| **Medium traffic** (10k visits) | ~$1.00 |

### Budget Protection

- **Budget limit:** $10/month
- **Alerts:** 50%, 80%, 100% thresholds
- **Email notifications:** Automatic

---

## 🔐 Security

### Security Features

| Feature | Implementation | Cost |
|---------|----------------|------|
| **HTTPS** | ACM certificate | Free |
| **DDoS Protection** | AWS Shield Standard | Free |
| **Private S3** | OAC (Origin Access Control) | Free |
| **Security Headers** | CloudFront Response Headers | Free |

### Content Security Policy (CSP)

```
default-src 'self';
script-src 'self' 'unsafe-inline';
style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdnjs.cloudflare.com;
font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com;
img-src 'self' data:;
connect-src 'self' https://formspree.io;
```

### Other Security Headers

| Header | Value | Purpose |
|--------|-------|---------|
| `Strict-Transport-Security` | max-age=31536000 | Force HTTPS |
| `X-Content-Type-Options` | nosniff | Prevent MIME sniffing |
| `X-Frame-Options` | DENY | Prevent clickjacking |

---

## 🐛 Troubleshooting

### Certificate Not Validating

**Symptom:** ACM certificate stuck in "Pending validation"

**Solution:**
```bash
# Check validation records exist
aws route53 list-resource-record-sets \
  --hosted-zone-id $(terraform output -raw route53_zone_id) \
  | grep CNAME

# Verify nameservers are correct
dig xurxo.cloud NS
```

**Cause:** Nameservers not updated in domain registrar.

---

### 403 Forbidden Error

**Symptom:** Website returns 403

**Solutions:**

1. **S3 bucket policy:**
```bash
aws s3api get-bucket-policy --bucket flask-cv-static-site
```

2. **CloudFront OAC:**
```bash
# Ensure OAC is configured
terraform apply -refresh-only
```

3. **Files exist:**
```bash
aws s3 ls s3://flask-cv-static-site/
```

---

### Changes Not Visible

**Symptom:** Updated files but site shows old content

**Solution:**
```bash
# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id E1UI2ORYQ3SFQO \
  --paths "/*"

# Wait 3-5 minutes
# Test in incognito mode
```

---

### Contact Form Not Working

**Symptom:** Form returns 403 error

**Cause:** CSP blocking Formspree

**Solution:** Ensure `connect-src` includes `https://formspree.io` in CSP:
```hcl
# In main.tf, security headers section
connect-src 'self' https://formspree.io;
```

Then:
```bash
terraform apply
# Wait 5 minutes for CloudFront update
```

---

### Terraform State Issues

**Symptom:** Resources exist but Terraform doesn't know about them

**Solution:**
```bash
# Import existing resource
terraform import aws_s3_bucket.website flask-cv-static-site

# Refresh state
terraform refresh

# Plan to verify
terraform plan
```

---

## 🔗 Related Repository

**Application Code:** [flask-cv-containerized-cicd](https://github.com/Xurxxo/flask-cv-containerized-cicd)

---

## 👤 Author

**Xurxo Astorgano** -

- 🌐 [xurxo.cloud](https://xurxo.cloud)
- 💼 [LinkedIn](https://linkedin.com/in/xurxoastorgano)
- 🐙 [GitHub](https://github.com/Xurxxo)
