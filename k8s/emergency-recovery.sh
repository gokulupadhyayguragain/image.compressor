#!/bin/bash
# Emergency recovery - restore working deployment

echo "🚨 EMERGENCY: Restoring last working deployment..."

# Scale down to 0 first
echo "📉 Scaling down deployments..."
kubectl scale deployment gocools-backend --replicas=0
kubectl scale deployment gocools-frontend --replicas=0

sleep 5

# Scale back up to 1
echo "📈 Scaling back up..."
kubectl scale deployment gocools-backend --replicas=1
kubectl scale deployment gocools-frontend --replicas=1

echo ""
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=gocools-backend --timeout=3m
kubectl wait --for=condition=ready pod -l app=gocools-frontend --timeout=3m

echo ""
echo "✅ Recovery complete!"
echo ""
echo "📊 Pod status:"
kubectl get pods -l 'app in (gocools-backend,gocools-frontend)'

echo ""
echo "🔍 Check logs if still failing:"
echo "  kubectl logs -l app=gocools-backend --tail=50"
echo "  kubectl logs -l app=gocools-frontend --tail=50"
echo ""
echo "🌐 Frontend URL:"
kubectl get svc gocools-frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo ""
