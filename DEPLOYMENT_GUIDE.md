# Kubernetes Deployment Guide - Cost Optimized

## 🚨 Critical Issues Fixed

### Issues That Were Causing High Bills:
1. ✅ **No Resource Limits** - Pods could consume unlimited CPU/memory
2. ✅ **Always Pull Images** - Unnecessary bandwidth costs
3. ✅ **No Health Checks** - Pods running but not responding, wasting resources
4. ✅ **No Auto-scaling** - Running more pods than needed
5. ✅ **No Volume Limits** - Unlimited storage usage

## 📋 What Was Changed

### Resource Limits Added:
- **Frontend**: 50m-200m CPU, 64Mi-128Mi Memory
- **Backend**: 100m-500m CPU, 256Mi-512Mi Memory
- **Storage**: 1Gi limit for input/output volumes

### Health Checks:
- Liveness probes restart unhealthy pods
- Readiness probes prevent traffic to unready pods

### Auto-scaling (HPA):
- Backend: 1-3 replicas based on CPU/Memory
- Frontend: 1-2 replicas based on CPU
- Scales down after 5 minutes of low usage

## 🚀 Quick Deploy

### Step 1: Apply the Fixed Configuration
```bash
cd k8s
chmod +x apply-fixes.sh
./apply-fixes.sh
```

### Step 2: (Optional) Apply Additional Cost Optimizations
```bash
kubectl apply -f cost-optimization.yaml
```

### Step 3: Verify Everything is Running
```bash
# Check pods
kubectl get pods

# Check resource usage
kubectl top pods

# Check auto-scaling
kubectl get hpa

# Get frontend URL
kubectl get svc gocools-frontend
```

## 💰 Expected Cost Savings

### Before Fixes:
- Pods consuming 100% of allocated node resources
- Always pulling images from registry (bandwidth costs)
- No auto-scaling = always running max capacity
- **Estimated**: $50-200/month depending on node type

### After Fixes:
- Resource limits prevent runaway usage
- Image pull only when needed
- Auto-scales to 1 pod during low traffic
- **Estimated**: $10-50/month for similar workload

## 📊 Monitoring Your Costs

### Check Resource Usage:
```bash
# Real-time pod resource usage
kubectl top pods

# Watch HPA scaling decisions
kubectl get hpa -w

# View pod events
kubectl describe pod <pod-name>
```

### Check if Pods Are Healthy:
```bash
# Check pod status
kubectl get pods

# Check logs
kubectl logs -l app=gocools-backend
kubectl logs -l app=gocools-frontend
```

## 🔧 Troubleshooting

### If Backend Pods Keep Restarting:
```bash
# Check logs
kubectl logs -l app=gocools-backend --tail=100

# Check health endpoint
kubectl port-forward svc/gocools-backend 3000:3000
curl http://localhost:3000/health
```

### If Frontend Can't Connect to Backend:
```bash
# Verify service exists
kubectl get svc gocools-backend

# Check if backend pods are ready
kubectl get pods -l app=gocools-backend

# Test from frontend pod
kubectl exec -it <frontend-pod-name> -- wget -O- http://gocools-backend:3000/health
```

### If Costs Are Still High:

1. **Check Node Types:**
   ```bash
   kubectl get nodes -o wide
   ```
   Consider using smaller instance types (t3.small instead of t3.large)

2. **Scale Down Further:**
   Edit `deployment.yaml` and reduce `minReplicas` to 1 for both HPA configs

3. **Use Spot Instances:**
   Configure your EKS node group to use spot instances for non-critical workloads

4. **Enable Cluster Autoscaler:**
   ```bash
   # This will scale down nodes when pods don't need them
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
   ```

## 🎯 Quick Actions to Take NOW

1. **Apply the fixes immediately:**
   ```bash
   kubectl apply -f k8s/deployment.yaml
   ```

2. **Monitor for 1 hour to ensure stability**

3. **Check your AWS Cost Explorer:**
   - Go to AWS Console → Cost Explorer
   - Filter by service: EKS, EC2, EBS
   - Compare today vs yesterday

4. **Set up Cost Alerts:**
   - AWS Console → Billing → Budgets
   - Create alert if spending exceeds $X/day

## 🚫 What NOT to Do

- ❌ Don't remove health checks to "fix" failing probes - fix the app instead
- ❌ Don't set `minReplicas: 0` - pods need time to start up
- ❌ Don't remove resource limits - they prevent cost runaway
- ❌ Don't use `type: LoadBalancer` for backend - ClusterIP is cheaper

## 📞 Need More Help?

1. Check pod logs: `kubectl logs -l app=gocools-backend --tail=100`
2. Check events: `kubectl get events --sort-by='.lastTimestamp'`
3. Describe failing pods: `kubectl describe pod <pod-name>`

## 🎉 Success Metrics

After applying these fixes, you should see:
- ✅ All pods in "Running" state
- ✅ Health checks passing (0/X restarts)
- ✅ HPA showing current utilization under 70%
- ✅ Costs starting to decrease within 24 hours
