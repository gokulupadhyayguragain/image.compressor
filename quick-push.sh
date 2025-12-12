#!/bin/bash
# Quick commit and push script

echo "📝 Committing all changes..."
git add .
git commit -m "Fix: K8s deployment with resource limits, health checks, HPA, and GitHub Actions workflow - $(date '+%Y-%m-%d %H:%M:%S')"

echo "🚀 Pushing to GitHub..."
git push origin main

echo ""
echo "✅ Changes pushed to GitHub!"
echo ""
echo "🔄 GitHub Actions will now:"
echo "  1. Build Docker images"
echo "  2. Push to ECR"
echo "  3. Deploy to EKS"
echo ""
echo "📊 Check progress:"
echo "  https://github.com/gokulupadhyayguragain/image.compressor/actions"
echo ""
echo "⏱️  Estimated time:"
echo "  - First deployment: 10-15 minutes (cluster creation)"
echo "  - Updates: 2-3 minutes"
echo ""
