# Deployment Guide - storage.emailsenderprox.online 🚀

## 📦 Option 1: Docker Deploy (Recommended)

### **Method A: Build & Push Docker Image**

```bash
# 1. Build Docker image
cd website-frontend
docker build -t smartcleaner-website:latest .

# 2. Tag image for your registry
docker tag smartcleaner-website:latest storage.emailsenderprox.online/smartcleaner-website:latest

# 3. Push to registry (if you have one)
docker push storage.emailsenderprox.online/smartcleaner-website:latest

# 4. On server, pull and run
docker pull storage.emailsenderprox.online/smartcleaner-website:latest
docker run -d -p 80:80 --name smartcleaner-web smartcleaner-website:latest
```

### **Method B: Copy files to server & build there**

```bash
# 1. Copy entire website-frontend folder to server
scp -r website-frontend/ user@storage.emailsenderprox.online:/var/www/

# 2. SSH into server
ssh user@storage.emailsenderprox.online

# 3. Build on server
cd /var/www/website-frontend
docker build -t smartcleaner-website .
docker run -d -p 80:80 --name smartcleaner-web smartcleaner-website
```

---

## 🌐 Option 2: Static File Deployment (Faster)

### **Build locally, upload build folder:**

```bash
# 1. Build the production files
cd website-frontend
npm run build

# 2. Upload build folder to server
scp -r build/* user@storage.emailsenderprox.online:/var/www/html/

# 3. Configure Nginx on server (if not using Docker)
```

---

## 🐳 Option 3: Docker Compose (Best for Multiple Services)

### **Create on server:**

```yaml
# docker-compose.yml
version: '3.8'

services:
  website:
    image: smartcleaner-website:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./ssl:/etc/nginx/ssl  # For HTTPS certificates
    restart: unless-stopped
    container_name: smartcleaner-web
```

```bash
# Run on server
docker-compose up -d
```

---

## 📋 Complete Step-by-Step

### **Sabse Easy Method:**

```bash
# 1. Local machine pe build karein
cd website-frontend
npm run build

# 2. Ek zip file banayen
cd build
zip -r smartcleaner-website.zip *

# 3. Server pe upload karein
scp smartcleaner-website.zip user@storage.emailsenderprox.online:/var/www/

# 4. Server pe extract karein
ssh user@storage.emailsenderprox.online
cd /var/www
unzip smartcleaner-website.zip -d /var/www/html/
```

---

## 🔧 Server Requirements

### **Docker Method:**
- Docker installed
- Port 80 available
- 512MB+ RAM

### **Static Files Method:**
- Nginx or Apache installed
- PHP not needed (pure React)

---

## 🌍 Domain Setup

```nginx
# Nginx config for storage.emailsenderprox.online
server {
    listen 80;
    server_name storage.emailsenderprox.online;
    
    root /var/www/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## ✅ Verify Deployment

After deployment, check:
- http://storage.emailsenderprox.online
- http://storage.emailsenderprox.online/#privacy

---

## 🚀 Quick Deploy Command

```bash
# One-liner to build and create deployment package
cd website-frontend && npm run build && cd build && tar -czf ../smartcleaner-web.tar.gz * && cd .. && echo "✅ Package ready: smartcleaner-web.tar.gz"
```

Upload `smartcleaner-web.tar.gz` to your server and extract!

---

**Need help?** Ask me about:
1. SSL/HTTPS setup
2. CI/CD pipeline
3. Custom domain configuration
4. Performance optimization
