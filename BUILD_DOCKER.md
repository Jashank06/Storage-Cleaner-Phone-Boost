# Docker Build & Deployment Guide 🐳

## Quick Start Commands

### 1. Build for Multiple Platforms and Push to Docker Hub

```bash
# Build and push multi-platform image (AMD64 + ARM64)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t jashank06/smartcleaner-frontend:latest \
  --push .
```

### 2. Build with Version Tag

```bash
# Build with specific version
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t jashank06/smartcleaner-frontend:latest \
  -t jashank06/smartcleaner-frontend:v1.0.0 \
  --push .
```

### 3. Build for Local Testing (Single Platform)

```bash
# Build for your current platform only
docker build -t smartcleaner-frontend:local .
```

## Prerequisites

### Setup Docker Buildx (One-time setup)

```bash
# Create a new builder instance
docker buildx create --name multiplatform-builder --use

# Bootstrap the builder
docker buildx inspect --bootstrap

# Verify builder supports multiple platforms
docker buildx ls
```

### Login to Docker Hub

```bash
# Login to your Docker Hub account
docker login

# Enter your Docker Hub credentials when prompted
```

## Available Commands

### Build Only (No Push)

```bash
# Build multi-platform without pushing
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t jashank06/smartcleaner-frontend:latest \
  .
```

### Run Locally

```bash
# Run the container locally
docker run -d -p 3000:80 --name smartcleaner jashank06/smartcleaner-frontend:latest

# Access at http://localhost:3000
```

### Using Docker Compose

```bash
# Start with docker-compose
docker-compose up -d

# Stop
docker-compose down

# View logs
docker-compose logs -f
```

## Image Details

- **Base Image:** nginx:alpine (lightweight)
- **Build Stage:** node:18-alpine
- **Size:** ~50MB (optimized production build)
- **Platforms:** linux/amd64, linux/arm64
- **Exposed Port:** 80 (mapped to 3000 in compose)

## Environment Variables

You can add environment variables by creating a `.env` file:

```env
REACT_APP_API_URL=https://api.smartcleaner.app
REACT_APP_VERSION=1.0.0
```

Then rebuild:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg REACT_APP_API_URL=https://api.smartcleaner.app \
  -t jashank06/smartcleaner-frontend:latest \
  --push .
```

## Deployment

### Pull and Run on Server

```bash
# Pull the image
docker pull jashank06/smartcleaner-frontend:latest

# Run the container
docker run -d \
  --name smartcleaner-frontend \
  -p 80:80 \
  --restart unless-stopped \
  jashank06/smartcleaner-frontend:latest
```

### Kubernetes Deployment (Optional)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: smartcleaner-frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: smartcleaner-frontend
  template:
    metadata:
      labels:
        app: smartcleaner-frontend
    spec:
      containers:
      - name: smartcleaner-frontend
        image: jashank06/smartcleaner-frontend:latest
        ports:
        - containerPort: 80
```

## Troubleshooting

### Build Fails

```bash
# Clean build cache
docker buildx prune -a -f

# Rebuild from scratch
docker buildx build --no-cache \
  --platform linux/amd64,linux/arm64 \
  -t jashank06/smartcleaner-frontend:latest \
  --push .
```

### Check Container Logs

```bash
# View logs
docker logs smartcleaner-frontend

# Follow logs
docker logs -f smartcleaner-frontend
```

### Access Container Shell

```bash
# Access running container
docker exec -it smartcleaner-frontend sh

# Check nginx config
docker exec smartcleaner-frontend cat /etc/nginx/conf.d/default.conf
```

## Production Optimization

The Docker image includes:
- ✅ Multi-stage build (smaller image size)
- ✅ Gzip compression enabled
- ✅ Static asset caching (1 year)
- ✅ Security headers configured
- ✅ Health check endpoint
- ✅ React Router support (SPA routing)
- ✅ Alpine Linux (minimal base image)

## Clean Up

```bash
# Stop and remove container
docker stop smartcleaner-frontend
docker rm smartcleaner-frontend

# Remove image
docker rmi jashank06/smartcleaner-frontend:latest

# Clean up build cache
docker buildx prune -a
```

---

**Ready to deploy!** 🚀

Your Smart Cleaner website will be available as a Docker container that can run anywhere!
