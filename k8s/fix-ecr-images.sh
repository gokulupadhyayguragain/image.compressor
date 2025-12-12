#!/bin/bash
# Quick fix script to update running deployment with ECR images

echo "🔧 Fixing deployment to use ECR images..."

# Get ECR registry from secrets or prompt
if [ -z "$ECR_REGISTRY" ]; then
    echo "Enter your ECR registry (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com):"
    read ECR_REGISTRY
fi

if [ -z "$ECR_REPOSITORY_BACKEND" ]; then
    ECR_REPOSITORY_BACKEND="gocools/backend"
fi

if [ -z "$ECR_REPOSITORY_FRONTEND" ]; then
    ECR_REPOSITORY_FRONTEND="gocools/frontend"
fi

echo ""
echo "📝 Using:"
echo "  Registry: $ECR_REGISTRY"
echo "  Backend: $ECR_REPOSITORY_BACKEND"
echo "  Frontend: $ECR_REPOSITORY_FRONTEND"
echo ""

# Update backend deployment
echo "🔄 Updating backend deployment..."
kubectl set image deployment/gocools-backend \
    backend=$ECR_REGISTRY/$ECR_REPOSITORY_BACKEND:latest

# Update frontend deployment
echo "🔄 Updating frontend deployment..."
kubectl set image deployment/gocools-frontend \
    frontend=$ECR_REGISTRY/$ECR_REPOSITORY_FRONTEND:latest

echo ""
echo "⏳ Waiting for rollouts..."
kubectl rollout status deployment/gocools-backend --timeout=5m
kubectl rollout status deployment/gocools-frontend --timeout=5m

echo ""
echo "✅ Deployment updated!"
echo ""
echo "📊 Pod status:"
kubectl get pods -l 'app in (gocools-backend,gocools-frontend)'

echo ""
echo "🌐 Frontend URL:"
kubectl get svc gocools-frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo ""
