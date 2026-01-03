# Zidni App - Production Deployment Guide

## Overview

This guide covers deploying all three components of the Zidni application:
1. **Flutter Mobile App** (iOS & Android)
2. **Laravel Backend** (API server)
3. **Python Companion Server** (Offline STT/LLM)

**Estimated Time:** 4-6 hours for first deployment

---

## Pre-Deployment Checklist

### ✅ Security Requirements (MUST COMPLETE)

- [ ] All **5 CRITICAL security fixes** applied (see `SECURITY_FIXES_APPLIED.md`)
- [ ] **Sentry monitoring** configured (see `SENTRY_SETUP.md`)
- [ ] **Firebase** project created and configured
- [ ] **Firestore security rules** deployed
- [ ] **TLS certificates** obtained for companion server
- [ ] **Environment variables** configured with production credentials
- [ ] **Security headers** middleware enabled
- [ ] **Database migrations** tested

### ✅ Testing Requirements

- [ ] All tests passing (`flutter test`, `php artisan test`, `pytest`)
- [ ] Manual QA completed on staging environment
- [ ] Load testing completed for Python companion
- [ ] Firebase authentication flow tested
- [ ] Offline mode tested

### ✅ Infrastructure Requirements

- [ ] Production server provisioned (recommended: 4GB RAM, 2 vCPU)
- [ ] Domain name configured (optional but recommended)
- [ ] SSL/TLS certificates obtained
- [ ] Database server ready (MySQL 8.0+)
- [ ] Redis server configured
- [ ] Backup strategy in place

---

## Part 1: Firebase Setup (30 minutes)

### Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Project name: `zidni-production`
4. Enable Google Analytics (recommended)
5. Create project

### Step 2: Enable Firebase Services

#### Enable Authentication
```
1. Firebase Console → Authentication → Get Started
2. Sign-in method → Email/Password → Enable
3. Sign-in method → Google → Enable (optional)
4. Save
```

#### Enable Firestore
```
1. Firebase Console → Firestore Database → Create database
2. Start in production mode
3. Location: Choose closest to your users
4. Create
```

### Step 3: Deploy Firestore Security Rules

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize project
cd /tmp/zidni-app
firebase init firestore

# Deploy security rules
firebase deploy --only firestore:rules

# Verify deployment
firebase firestore:rules:get
```

The rules are in `firestore.rules` and enforce:
- ✅ User authentication required
- ✅ Users can only access their own data
- ✅ Owner validation on all operations
- ✅ Type validation for required fields

### Step 4: Generate Flutter Firebase Configuration

```bash
cd zidni_mobile

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (interactive)
flutterfire configure --project=zidni-production

# This generates lib/firebase_options.dart
```

**Manual Alternative:**

If you prefer manual setup, replace values in `lib/firebase_options.dart`:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',        // From Firebase Console
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'zidni-production',
  storageBucket: 'zidni-production.appspot.com',
);
```

Get these values from:
**Firebase Console → Project Settings → General → Your apps**

---

## Part 2: Laravel Backend Deployment (1-2 hours)

### Server Requirements

- PHP 8.2+
- MySQL 8.0+ or PostgreSQL 14+
- Redis 7+
- Composer 2.x
- Nginx or Apache

### Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install PHP 8.2 and extensions
sudo apt install -y php8.2-fpm php8.2-mysql php8.2-redis php8.2-xml \
  php8.2-mbstring php8.2-curl php8.2-zip php8.2-bcmath

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install Nginx
sudo apt install -y nginx

# Install MySQL
sudo apt install -y mysql-server
sudo mysql_secure_installation

# Install Redis
sudo apt install -y redis-server
sudo systemctl enable redis-server
```

### Step 2: Clone Repository

```bash
# Create application directory
sudo mkdir -p /var/www/zidni
sudo chown $USER:$USER /var/www/zidni

# Clone repository
cd /var/www
git clone https://github.com/lemneya/zidni-app.git zidni
cd zidni

# Install dependencies
composer install --no-dev --optimize-autoloader
```

### Step 3: Configure Environment

```bash
# Copy production environment
cp .env.example .env.production
ln -s .env.production .env

# Generate application key
php artisan key:generate

# Edit .env with production values
nano .env
```

**Required environment variables:**

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=                     # Generated above
APP_URL=https://api.zidni.app

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=zidni_production
DB_USERNAME=zidni_user
DB_PASSWORD=                 # Strong password

CACHE_DRIVER=redis
SESSION_DRIVER=database
QUEUE_CONNECTION=redis

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=              # Set Redis password
REDIS_PORT=6379

# Sentry (from SENTRY_SETUP.md)
SENTRY_LARAVEL_DSN=          # Your Sentry DSN

# Mail (configure your SMTP)
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=
MAIL_PASSWORD=
```

### Step 4: Database Setup

```bash
# Create database and user
sudo mysql -u root -p

CREATE DATABASE zidni_production CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'zidni_user'@'localhost' IDENTIFIED BY 'STRONG_PASSWORD_HERE';
GRANT ALL PRIVILEGES ON zidni_production.* TO 'zidni_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Run migrations
php artisan migrate --force

# (Optional) Seed initial data
php artisan db:seed --force
```

### Step 5: Configure Nginx

Create `/etc/nginx/sites-available/zidni`:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name api.zidni.app;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name api.zidni.app;

    root /var/www/zidni/public;
    index index.php;

    # SSL certificates (from Let's Encrypt or your provider)
    ssl_certificate /etc/letsencrypt/live/api.zidni.app/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.zidni.app/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;

    # Security headers (additional to Laravel middleware)
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logging
    access_log /var/log/nginx/zidni-access.log;
    error_log /var/log/nginx/zidni-error.log;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Client max body size
    client_max_body_size 50M;
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/zidni /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Step 6: Install SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d api.zidni.app

# Test auto-renewal
sudo certbot renew --dry-run
```

### Step 7: Configure Queue Worker

Create systemd service `/etc/systemd/system/zidni-queue.service`:

```ini
[Unit]
Description=Zidni Queue Worker
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/zidni
ExecStart=/usr/bin/php /var/www/zidni/artisan queue:work --sleep=3 --tries=3 --max-time=3600
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable zidni-queue
sudo systemctl start zidni-queue
sudo systemctl status zidni-queue
```

### Step 8: Configure Sentry (Laravel)

```bash
# Install Sentry package
composer require sentry/sentry-laravel

# Publish configuration
php artisan sentry:publish --dsn="YOUR_LARAVEL_SENTRY_DSN"

# Test Sentry
php artisan sentry:test
```

### Step 9: Optimize Laravel

```bash
# Cache configuration
php artisan config:cache

# Cache routes
php artisan route:cache

# Cache views
php artisan view:cache

# Optimize autoloader
composer dump-autoload --optimize

# Set permissions
sudo chown -R www-data:www-data /var/www/zidni/storage
sudo chown -R www-data:www-data /var/www/zidni/bootstrap/cache
sudo chmod -R 755 /var/www/zidni/storage
sudo chmod -R 755 /var/www/zidni/bootstrap/cache
```

---

## Part 3: Python Companion Server Deployment (1 hour)

### Step 1: Server Setup

```bash
# Install Python 3.11
sudo apt install -y python3.11 python3.11-venv python3-pip

# Create application directory
sudo mkdir -p /opt/zidni-companion
sudo chown $USER:$USER /opt/zidni-companion

# Clone or copy companion code
cp -r /tmp/zidni-app/local_companion/* /opt/zidni-companion/
cd /opt/zidni-companion
```

### Step 2: Create Virtual Environment

```bash
# Create venv
python3.11 -m venv venv

# Activate venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Install Whisper model (SLOW - takes 5-10 minutes)
python -c "import whisper; whisper.load_model('small')"
```

### Step 3: Generate TLS Certificates

**Option 1: Self-Signed (Testing Only)**
```bash
openssl req -x509 -newkey rsa:4096 -nodes \
  -out /opt/zidni-companion/cert.pem \
  -keyout /opt/zidni-companion/key.pem \
  -days 365 \
  -subj "/CN=192.168.4.1"
```

**Option 2: Let's Encrypt (Production)**

Follow `local_companion/HTTPS_REQUIRED.md` for full setup.

### Step 4: Configure Environment

Create `/opt/zidni-companion/.env`:

```bash
HOST=0.0.0.0
PORT=8787
SENTRY_DSN=YOUR_PYTHON_SENTRY_DSN
COMPANION_ENV=production
VERSION=1.0.0
```

### Step 5: Create Systemd Service

Create `/etc/systemd/system/zidni-companion.service`:

```ini
[Unit]
Description=Zidni Local Companion Server
After=network.target

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=/opt/zidni-companion
Environment="PATH=/opt/zidni-companion/venv/bin"
EnvironmentFile=/opt/zidni-companion/.env

ExecStart=/opt/zidni-companion/venv/bin/gunicorn \
    --bind 0.0.0.0:8787 \
    --certfile=/opt/zidni-companion/cert.pem \
    --keyfile=/opt/zidni-companion/key.pem \
    --workers 2 \
    --timeout 120 \
    --access-logfile /var/log/zidni-companion/access.log \
    --error-logfile /var/log/zidni-companion/error.log \
    --log-level info \
    server:app

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Create log directory:
```bash
sudo mkdir -p /var/log/zidni-companion
sudo chown www-data:www-data /var/log/zidni-companion
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable zidni-companion
sudo systemctl start zidni-companion
sudo systemctl status zidni-companion
```

### Step 6: Test Companion Server

```bash
# Test health endpoint
curl -k https://192.168.4.1:8787/health

# Expected response:
{
  "status": "healthy",
  "version": "1.0.0",
  "endpoints": ["/health", "/stt", "/llm"]
}
```

---

## Part 4: Flutter Mobile App Deployment (2-3 hours)

### Android Deployment

#### Step 1: Configure Signing

Create `zidni_mobile/android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=zidni-release
storeFile=/path/to/keystore.jks
```

Generate keystore:
```bash
keytool -genkey -v -keystore ~/zidni-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias zidni-release
```

#### Step 2: Build Release APK/AAB

```bash
cd zidni_mobile

# Build APK with Sentry
flutter build apk --release \
  --dart-define=SENTRY_DSN="YOUR_FLUTTER_SENTRY_DSN"

# Build AAB for Play Store
flutter build appbundle --release \
  --dart-define=SENTRY_DSN="YOUR_FLUTTER_SENTRY_DSN"
```

Output:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

#### Step 3: Deploy to Google Play

1. Go to https://play.google.com/console
2. Create app "Zidni"
3. Upload AAB to Internal Testing track
4. Fill out store listing
5. Submit for review

### iOS Deployment

#### Step 1: Configure Xcode

```bash
cd zidni_mobile
flutter build ios --release \
  --dart-define=SENTRY_DSN="YOUR_FLUTTER_SENTRY_DSN"

open ios/Runner.xcworkspace
```

In Xcode:
1. Select Runner → Signing & Capabilities
2. Team: Select your Apple Developer account
3. Bundle Identifier: `com.zidni.zidniMobile`

#### Step 2: Archive and Upload

1. Product → Archive
2. Window → Organizer
3. Select archive → Distribute App
4. App Store Connect → Upload
5. Submit for review in App Store Connect

---

## Part 5: Post-Deployment Verification

### 1. Health Checks

```bash
# Laravel backend
curl https://api.zidni.app/up
# Expected: {"status":"ok"}

# Python companion
curl -k https://192.168.4.1:8787/health
# Expected: {"status":"healthy"...}
```

### 2. Sentry Verification

1. Go to https://sentry.io
2. Check all 3 projects for incoming events
3. Verify release versions are correct

### 3. Firebase Verification

1. Firebase Console → Authentication → Users
2. Create test user
3. Firebase Console → Firestore → Data
4. Verify security rules are active (lock icon)

### 4. Database Verification

```bash
# Check migrations
php artisan migrate:status

# Check database connectivity
php artisan tinker
>>> DB::connection()->getPdo();
```

### 5. Mobile App Testing

- [ ] Install app on test device
- [ ] Complete signup flow
- [ ] Test Firebase authentication
- [ ] Create deal folder
- [ ] Test STT (online mode)
- [ ] Test STT (offline mode with companion)
- [ ] Test subscription/entitlement check
- [ ] Verify Sentry error tracking

---

## Part 6: Monitoring & Maintenance

### Daily Checks

```bash
# Check server health
systemctl status nginx
systemctl status zidni-queue
systemctl status zidni-companion

# Check logs
tail -f /var/log/nginx/zidni-error.log
tail -f /var/log/zidni-companion/error.log
tail -f /var/www/zidni/storage/logs/laravel.log

# Check Sentry dashboard
```

### Weekly Maintenance

```bash
# Update dependencies
cd /var/www/zidni
git pull origin main
composer update
php artisan migrate --force
php artisan config:cache

# Restart services
sudo systemctl restart zidni-queue
sudo systemctl restart zidni-companion
```

### Backup Strategy

**Daily automated backups:**

Create `/usr/local/bin/zidni-backup.sh`:

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/zidni"

# Database backup
mysqldump -u zidni_user -p'PASSWORD' zidni_production | gzip > "$BACKUP_DIR/db_$DATE.sql.gz"

# Application backup
tar -czf "$BACKUP_DIR/app_$DATE.tar.gz" /var/www/zidni

# Firestore backup (via gcloud)
gcloud firestore export gs://zidni-backups/firestore_$DATE

# Cleanup old backups (keep 30 days)
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete
```

Add to cron:
```bash
sudo crontab -e
0 2 * * * /usr/local/bin/zidni-backup.sh
```

---

## Troubleshooting

### Laravel 500 Errors

```bash
# Check logs
tail -f /var/www/zidni/storage/logs/laravel.log

# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Check permissions
sudo chown -R www-data:www-data storage bootstrap/cache
```

### Companion Server Not Responding

```bash
# Check status
sudo systemctl status zidni-companion

# Check logs
sudo journalctl -u zidni-companion -f

# Restart service
sudo systemctl restart zidni-companion
```

### Flutter App Crashes

1. Check Sentry dashboard for stack traces
2. Verify Firebase configuration
3. Check companion server connectivity
4. Review device logs (Android: `adb logcat`, iOS: Xcode Console)

---

## Rollback Procedures

### Laravel Rollback

```bash
cd /var/www/zidni

# Rollback last migration
php artisan migrate:rollback --step=1

# Rollback to previous release
git checkout previous-release-tag
composer install --no-dev
php artisan migrate --force
php artisan config:cache

sudo systemctl restart zidni-queue
```

### Mobile App Rollback

- **Android:** Deactivate new release in Play Console, promote previous version
- **iOS:** Remove new version from App Store Connect, previous version auto-restores

---

## Security Checklist

After deployment, verify:

- [ ] HTTPS enabled on all endpoints
- [ ] Firestore security rules deployed
- [ ] Environment variables secured (not in git)
- [ ] Database passwords are strong
- [ ] Redis password set
- [ ] SSH keys only (no password auth)
- [ ] Firewall configured (UFW or iptables)
- [ ] Fail2ban installed for brute-force protection
- [ ] Automatic security updates enabled
- [ ] Sentry monitoring active
- [ ] Backup restoration tested

---

## Support & Resources

- **Documentation:** `/tmp/zidni-app/` - All setup guides
- **Security Fixes:** `SECURITY_FIXES_APPLIED.md`
- **Sentry Setup:** `SENTRY_SETUP.md`
- **Comprehensive Analysis:** `COMPREHENSIVE_ANALYSIS_REPORT.md`
- **GitHub Issues:** https://github.com/lemneya/zidni-app/issues

**Need help?** Create an issue or consult the documentation above.

---

**Deployment complete! 🎉**

Your Zidni app is now running in production with:
✅ Secure HTTPS connections
✅ Error tracking with Sentry
✅ Firebase authentication & database
✅ Automated backups
✅ CI/CD pipeline ready

Monitor Sentry dashboard and server health regularly!
