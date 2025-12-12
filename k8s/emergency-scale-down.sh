#!/bin/bash

echo "🚨 EMERGENCY: Scaling down to minimum to reduce costs immediately..."
echo ""

# Scale down to 1 replica for all deployments
echo "📉 Scaling backend to 1 replica..."
kubectl scale deployment gocools-backend --replicas=1

echo "📉 Scaling frontend to 1 replica..."
kubectl scale deployment gocools-frontend --replicas=1

# Optionally, you can pause the HPA temporarily
echo "⏸️  Pausing auto-scaling temporarily..."
kubectl patch hpa gocools-backend-hpa -p '{"spec":{"minReplicas":1,"maxReplicas":1}}'
kubectl patch hpa gocools-frontend-hpa -p '{"spec":{"minReplicas":1,"maxReplicas":1}}'

echo ""
echo "✅ Emergency scale down complete!"
echo ""
echo "Current status:"
kubectl get pods
echo ""
kubectl get hpa
echo ""
echo "💰 This should reduce your costs immediately."
echo ""
echo "⚠️  To restore normal scaling later, run:"
echo "   kubectl apply -f deployment.yaml"
echo ""
