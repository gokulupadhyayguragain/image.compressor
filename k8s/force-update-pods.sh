#!/bin/bash
# Force delete and restart pods immediately

echo "🚨 Force updating pods with new images..."

# Delete old pods forcefully
echo "💥 Deleting old backend pods..."
kubectl delete pods -l app=gocools-backend --grace-period=0 --force

echo "💥 Deleting old frontend pods..."
kubectl delete pods -l app=gocools-frontend --grace-period=0 --force

echo ""
echo "⏳ Waiting for new pods to start..."
sleep 10

echo ""
echo "📊 Pod status:"
kubectl get pods -l 'app in (gocools-backend,gocools-frontend)'

echo ""
echo "⏳ Waiting for rollout..."
kubectl rollout status deployment/gocools-backend --timeout=3m
kubectl rollout status deployment/gocools-frontend --timeout=3m

echo ""
echo "✅ Pods updated!"
echo ""
echo "🧪 Test your app now - should show:"
echo "  - Quality 80 compression"
echo "  - No slider"
echo "  - Better compression ratios"
echo ""
