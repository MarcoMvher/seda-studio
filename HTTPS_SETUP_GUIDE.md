# 🔒 Set Up HTTPS for Your Django Backend on VPS

## Problem:
Your web app on GitHub Pages uses **HTTPS** but your backend API uses **HTTP**.
Browsers block "Mixed Content" (HTTP requests from HTTPS pages) for security.

## Solution: Set up FREE SSL with Let's Encrypt

---

## 🚀 Quick Setup Guide for HTTPS on Your VPS

### Your Current Setup:
- **VPS IP:** 62.169.26.136
- **Port:** 8080 (Django backend)
- **Domain:** None yet (using IP address)

### Two Options:

---

## Option 1: Get a Domain (Recommended) + SSL

### Step 1: Get a Domain
Buy a cheap domain:
- **Namecheap:** $8-12/year
- **GoDaddy:** $10-15/year
- **Freenom:** Free (limited extensions)

### Step 2: Point Domain to Your VPS
1. Go to your domain registrar's DNS settings
2. Add an **A Record**:
   - **Name:** `@` (root) or `www`
   - **Type:** A
   - **Value:** `62.169.26.136`
   - **TTL:** 3600 (or default)

### Step 3: Set up SSL with Certbot

**SSH into your VPS:**
```bash
ssh root@62.169.26.136
```

**Install Certbot:**
```bash
sudo apt update
sudo apt install certbot python3-certbot nginx
```

**Get SSL Certificate:**
```bash
# Stop your Django app temporarily
# Replace with your actual start command
pkill -f gunicorn

# Get certificate (HTTP-only validation)
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Your certificate files will be saved to:
# /etc/letsencrypt/live/yourdomain.com/fullchain.pem
# /etc/letsencrypt/live/yourdomain.com/privkey.pem
```

### Step 4: Update Django to Use HTTPS

**Edit backend settings:**
```bash
cd /home/marco-maher/Projects/Seda\ Studio/backend
nano seda_project/settings.py
```

**Add/update these settings:**
```python
# Add to settings.py
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True

# If behind proxy
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
```

### Step 5: Run Django with Gunicorn + SSL

```bash
# From your backend directory
cd /home/marco-maher/Projects/Seda\ Studio/backend

# Run with gunicorn (you can automate this with a service)
gunicorn --bind 0.0.0.0:443 --key /etc/letsencrypt/live/yourdomain.com/privkey.pem --cert /etc/letsencrypt/live/yourdomain.com/fullchain.pem seda_project.wsgi:application
```

### Step 6: Update Flutter Config

**Edit `lib/config/app_config.dart`:**
```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://yourdomain.com', // Use HTTPS with your domain
  // For local development: 'http://localhost:8000'
);
```

---

## Option 2: Use HTTPS with IP Address (Advanced)

### Alternative: Cloudflare Tunnel (Free)

If you don't want to buy a domain, use Cloudflare Tunnel:

#### 1. Install Cloudflare Tunnel
```bash
# Download for Linux
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
sudo mv cloudflared-linux-amd64 cloudflared
sudo chmod +x cloudflared
```

#### 2. Authenticate
```bash
cloudflared tunnel login
```

#### 3. Create Tunnel
```bash
cloudflared tunnel create seda-studio-tunnel
```

#### 4. Configure Tunnel
Create config file `~/.cloudflared/config.yml`:
```yaml
tunnel: seda-studio-tunnel
credentials-file: /root/.cloudflared/<id>.json

ingress:
  - hostname: yourdomain.com
    service: http://localhost:8080
  - hostname: marcomvher.github.io
    service: http://localhost:8080
```

#### 5. Run Tunnel
```bash
cloudflared tunnel run
```

This will give you a public HTTPS URL like: `https://seda-studio-tunnel.yourdomain.com`

---

## 🎯 Recommended Approach

### For Production:
1. **Buy a domain** (~$10/year)
2. **Set up SSL** with Certbot (FREE)
3. **Use Nginx** as reverse proxy (secure & production-ready)

### For Testing/Development:
1. **Use Cloudflare Tunnel** (FREE)
2. **Test with HTTPS URL**
3. **Purchase domain when ready**

---

## 🔧 Quick Fix (For Testing)

### If you just want to test the web app NOW:

1. **Disable browser security** (NOT recommended):
   - Open Chrome
   - Visit: `chrome://flags/#unsafely-treat-insecure-origin-as-secure`
   - Enable "Allow insecure connections"
   - Add: `https://marcomvher.github.io`
   - **This is temporary!**

2. **Better: Use local testing:**
   ```bash
   # Build web app locally
   flutter build web

   # Serve locally
   python3 -m http.server 8000 --directory build/web

   # Open http://localhost:8000
   ```

---

## 📋 What You Need to Decide:

1. **For immediate testing:** Use local development server
2. **For production:** Buy a domain + set up SSL
3. **For free HTTPS:** Use Cloudflare Tunnel

---

## ✅ After Setting Up HTTPS:

1. **Update `lib/config/app_config.dart`**
2. **Rebuild web app:** `flutter build web`
3. **Deploy to GitHub Pages**
4. **Everything works!** 🎉

---

**Which option would you like to use?** 🚀

I recommend getting a domain (~$10/year) and setting up proper SSL with Certbot. It's professional, secure, and reliable.
