#!/bin/bash

echo "🚀 Starting deployment process..."

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo "📦 Initializing git repository..."
    git init
fi

# Add all changes
echo "➕ Adding all changes..."
git add .

# Commit changes
echo "💾 Committing changes..."
git commit -m "Fix: Updated K8s deployment with resource limits, health checks, and nginx proxy config - $(date '+%Y-%m-%d %H:%M:%S')"

# Set main branch
echo "🔧 Setting main branch..."
git branch -M main

# Push to origin
echo "⬆️  Pushing to GitHub..."
git push -u origin main

echo ""
echo "✅ Code pushed to GitHub!"
echo ""
echo "🐳 Building and pushing Docker images..."

# Build and push backend
echo "📦 Building backend image..."
docker build -f docker/backend.dockerfile -t gocools/backend:latest .
echo "⬆️  Pushing backend image..."
docker push gocools/backend:latest

# Build and push frontend
echo "📦 Building frontend image..."
docker build -f docker/frontend.dockerfile -t gocools/frontend:latest .
echo "⬆️  Pushing frontend image..."
docker push gocools/frontend:latest

echo ""
echo "🎯 Applying Kubernetes deployment..."
kubectl apply -f k8s/deployment.yaml

echo ""
echo "🔄 Restarting deployments to pull new images..."
kubectl rollout restart deployment/gocools-backend
kubectl rollout restart deployment/gocools-frontend

echo ""
echo "⏳ Waiting for deployments to be ready..."
kubectl rollout status deployment/gocools-backend --timeout=5m
kubectl rollout status deployment/gocools-frontend --timeout=5m

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Current status:"
kubectl get pods
echo ""
kubectl get svc
echo ""
echo "🌐 Get your app URL:"
echo "kubectl get svc gocools-frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
echo ""
