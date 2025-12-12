#!/bin/bash

echo "🚀 Applying Kubernetes fixes to reduce costs and improve stability..."
echo ""

# Apply the updated deployment
echo "📦 Applying deployment with resource limits and health checks..."
kubectl apply -f deployment.yaml

echo ""
echo "⏳ Waiting for deployments to be ready..."
kubectl rollout status deployment/gocools-backend -n default --timeout=5m
kubectl rollout status deployment/gocools-frontend -n default --timeout=5m

echo ""
echo "✅ Checking pod status..."
kubectl get pods -l app=gocools-backend
kubectl get pods -l app=gocools-frontend

echo ""
echo "📊 Checking HPA status..."
kubectl get hpa

echo ""
echo "🔍 Checking services..."
kubectl get svc

echo ""
echo "✨ Deployment complete!"
echo ""
echo "💡 Cost Savings Tips:"
echo "  1. Resource limits are now set - pods won't consume unlimited resources"
echo "  2. HPA will scale down when traffic is low"
echo "  3. Image pull policy changed to IfNotPresent - reduces bandwidth costs"
echo "  4. Health probes will restart failing pods automatically"
echo ""
echo "📈 To monitor your application:"
echo "  kubectl top pods"
echo "  kubectl get hpa -w"
echo ""
echo "🌐 To get your frontend URL:"
echo "  kubectl get svc gocools-frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
echo ""
