# 🏛️ Infrastructure Architecture

Technical documentation for the AWS infrastructure powering [xurxo.cloud](https://xurxo.cloud).

---

## 📊 Architecture Diagram

![AWS Architecture](./diagrams/architecture.svg)

---

## 🔄 Request Flow

```
1. User types: https://xurxo.cloud
           │
           ▼
2. DNS Resolution (Route 53)
   - xurxo.cloud → CloudFront distribution
           │
           ▼
3. CloudFront Edge Location
   - Nearest edge to user (450+ locations)
   - Check cache
           │
           ├─── Cache HIT ──▶ Return cached content
           │
           └─── Cache MISS ──▶ Request from S3
                                      │
                                      ▼
4. S3 Bucket (Origin)
   - Fetch file → Return to CloudFront
           │
           ▼
5. CloudFront
   - Cache response
   - Add security headers
   - Compress (gzip/brotli)
           │
           ▼
6. User receives content (HTTPS)
```

---

## 🗂️ AWS Resources

### 1. S3 Bucket

**Purpose:** Store static website files

**Access:** Private (CloudFront only via OAC)

---

### 2. S3 Public Access Block

**Purpose:** Prevent accidental public exposure

**Settings:**
- `block_public_acls = true`
- `block_public_policy = true`
- `ignore_public_acls = true`
- `restrict_public_buckets = true`

---

### 3. CloudFront Distribution

**Purpose:** Global CDN with HTTPS and caching

**Key Settings:**

| Setting | Value | Purpose |
|---------|-------|---------|
| `price_class` | PriceClass_100 | NA + EU edges (cheaper) |
| `default_root_object` | index.html | Serve index.html for / |
| `viewer_protocol_policy` | redirect-to-https | Force HTTPS |
| `compress` | true | Enable gzip/brotli |
| `default_ttl` | 86400 | Cache 24 hours |

---

### 4. CloudFront Response Headers Policy

**Purpose:** Add security headers to all responses

| Header | Value | Purpose |
|--------|-------|---------|
| `Strict-Transport-Security` | max-age=31536000 | Force HTTPS |
| `X-Content-Type-Options` | nosniff | Prevent MIME sniffing |
| `X-Frame-Options` | DENY | Block iframe embedding |
| `Content-Security-Policy` | See below | Control resources |
```

---

### 5. CloudFront Function

**Purpose:** URL rewriting for clean URLs

**Examples:**
- `/whoami` → `/whoami.html`
- `/` → `/index.html`
- `/static/css/style.css` → unchanged

---

### 6. Route 53 Hosted Zone

**Purpose:** DNS management

**Records:**
- `xurxo.cloud` → CloudFront (A record alias)
- `www.xurxo.cloud` → CloudFront (A record alias)

**Nameservers:** Configured in Namecheap (domain registrar)

---

### 7. ACM AWS Certificate Manager

**Purpose:** Free SSL/TLS certificate

**Coverage:**
- `xurxo.cloud` (apex)
- `*.xurxo.cloud` (all subdomains)

**Region:** us-east-1 (required for CloudFront)

**Renewal:** Automatic

---

### 8. CloudWatch

**Purpose:** Monitoring and logging

**Resources:**
- Log Group: 30-day retention
- Metric Alarm: >10,000 requests/hour triggers alert

---

### 9. AWS Budget

**Purpose:** Cost monitoring

**Configuration:**
- Limit: $10/month
- Alerts: 50%, 80%, 100% thresholds
- Notifications: Email

---

## 🌍 Domain Configuration

### Domain Purchase

**Registrar:** Namecheap  
**Domain:** xurxo.cloud  
**Cost:** ~$2.75/year

### DNS Migration to Route 53

1. Terraform creates Route 53 hosted zone
2. Get nameservers: `terraform output route53_nameservers`
3. Update in Namecheap: Domain → Custom DNS → Add 4 nameservers
4. Wait 15-48 hours for propagation

---

## 💰 Cost Analysis

| Service | Monthly Cost |
|---------|--------------|
| S3 Storage (2GB) | $0.05 |
| CloudFront | $0.00 (free tier) |
| Route 53 | $0.50 |
| ACM | $0.00 |
| CloudWatch | $0.00 (free tier) |
| **Total** | **~$0.55** |


---

## 🔐 Security Architecture

```
Internet
    │
    ▼
┌─────────────────────────┐
│   AWS Shield Standard   │  ← DDoS protection
└─────────────────────────┘
    │
    ▼
┌─────────────────────────┐
│     CloudFront          │  ← TLS, caching
│   Security Headers      │  ← CSP, HSTS
└─────────────────────────┘
    │
    ▼
┌─────────────────────────┐
│    Origin Access        │  ← Signed requests
│      Control            │
└─────────────────────────┘
    │
    ▼
┌─────────────────────────┐
│      S3 Bucket          │  ← Private
└─────────────────────────┘
```

### Security Checklist

| Feature |
|---------|
| HTTPS everywhere | 
| Transport Layer Security 1.2+ | 
| HSTS | 
| Content Security Policy | 
| X-Frame-Options | 
| Private S3 | 
| DDoS basic | 
| Budget alerts |

---

## 🔄 CI/CD Integration

**Repository:** [flask-cv-containerized-cicd](https://github.com/Xurxxo/flask-cv-containerized-cicd)

**Flow:**
```
Push to main → GitHub Actions → Generate HTML → S3 → CloudFront → Live
```

**Required IAM Permissions:**
- `s3:PutObject`, `s3:GetObject`, `s3:DeleteObject`, `s3:ListBucket`
- `cloudfront:CreateInvalidation`

---

## 📚 References

- [AWS S3 Static Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Developer Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

