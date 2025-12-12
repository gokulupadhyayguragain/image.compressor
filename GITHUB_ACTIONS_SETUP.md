# GitHub Actions Setup for EKS Deployment

This guide will help you set up automated deployment to AWS EKS using GitHub Actions.

## 🔧 Required GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret

Add the following secrets:

### AWS Credentials
```
AWS_ACCESS_KEY_ID         = Your AWS access key
AWS_SECRET_ACCESS_KEY     = Your AWS secret key
AWS_REGION                = us-east-1 (or your preferred region)
```

### EKS Configuration
```
EKS_CLUSTER_NAME          = gocools-cluster (or your cluster name)
CREATE_EKS                = true (set to 'false' if cluster already exists)
```

### ECR Configuration
```
ECR_REGISTRY              = <your-aws-account-id>.dkr.ecr.us-east-1.amazonaws.com
ECR_REPOSITORY_BACKEND    = gocools/backend
ECR_REPOSITORY_FRONTEND   = gocools/frontend
```

## 📋 How to Get Your ECR Registry URL

1. Log in to AWS Console
2. Go to ECR (Elastic Container Registry)
3. Your registry URL format: `<account-id>.dkr.ecr.<region>.amazonaws.com`
4. Example: `123456789012.dkr.ecr.us-east-1.amazonaws.com`

## 🚀 How It Works

### Automatic Deployment (on git push)
Every time you push to the `main` branch:
1. ✅ Builds Docker images (backend & frontend)
2. ✅ Pushes images to AWS ECR
3. ✅ Creates EKS cluster (if `CREATE_EKS=true` and cluster doesn't exist)
4. ✅ Deploys to EKS cluster
5. ✅ Shows your app URL

### Manual Actions (via GitHub UI)
Go to Actions tab → "Build, push Docker images to ECR and deploy to EKS" → Run workflow

Choose action:
- **deploy**: Manually trigger deployment
- **destroy-cluster**: Delete EKS cluster to stop costs

## 💡 Cost Optimization Tips

### 1. Turn Cluster OFF When Not in Use
```bash
# In GitHub Actions tab, run workflow with action: destroy-cluster
```
This will:
- Delete the EKS cluster
- Clean up ECR images
- **Stop all costs immediately**

### 2. Turn Cluster ON When Needed
```bash
# Set CREATE_EKS=true in secrets
# Push code or run workflow with action: deploy
```

### 3. Monitor Costs
- AWS Console → Billing Dashboard
- Set up budget alerts
- Expected costs:
  - Cluster running: $50-100/month
  - Cluster stopped: $0-5/month (ECR storage only)

## 🔍 Troubleshooting

### "Cluster not found" error
- Make sure `EKS_CLUSTER_NAME` secret matches your actual cluster name
- Or set `CREATE_EKS=true` to auto-create

### Images not updating
- Check ECR registry URL is correct
- Verify AWS credentials have ECR permissions
- Look at GitHub Actions logs for build errors

### 404 errors on website
- ✅ Already fixed! Updated nginx config to properly proxy `/api/` requests
- Backend health check: `http://your-url/health`
- If still issues, check pod logs: `kubectl logs -l app=gocools-backend`

### Pods keep restarting
- Check resource limits aren't too low
- View logs: `kubectl logs <pod-name>`
- Describe pod: `kubectl describe pod <pod-name>`

## 📊 Monitoring Your Deployment

### Via GitHub Actions Output
After deployment completes, the workflow shows:
- ✅ Frontend URL (LoadBalancer hostname)
- ✅ Pod status
- ✅ Service status
- ✅ HPA status

### Via kubectl (if you have access)
```bash
# Connect to cluster
aws eks update-kubeconfig --name gocools-cluster --region us-east-1

# Check everything
kubectl get pods
kubectl get svc
kubectl get hpa
kubectl top pods

# Get URL
kubectl get svc gocools-frontend
```

## 🎯 Quick Start Checklist

- [ ] Add all GitHub secrets (AWS credentials, EKS config, ECR config)
- [ ] Set `CREATE_EKS=true` if you want auto-cluster creation
- [ ] Push code to `main` branch
- [ ] Wait ~10-15 minutes for cluster creation + deployment
- [ ] Check Actions tab for deployment URL
- [ ] Test your app!
- [ ] When done, run "destroy-cluster" action to save money

## ⚠️ Important Notes

1. **First deployment takes 10-15 minutes** (cluster creation)
2. **Subsequent deploys take 2-3 minutes** (just image updates)
3. **Always destroy cluster when not in use** to save costs
4. **ECR images are kept** even after cluster deletion (small storage cost)
5. **The workflow creates t3.small nodes** (cost-optimized, can change in scripts/eksctl.sh)

## 🆘 Emergency: Stop All Costs NOW

If costs are too high:

1. Go to GitHub Actions
2. Run workflow → Choose "destroy-cluster"
3. Or manually in AWS Console:
   - Go to EKS → Delete cluster
   - Go to EC2 → Terminate instances
   - Go to Load Balancers → Delete load balancers

## ✅ What's Been Fixed

- ✅ Resource limits added (prevents cost overrun)
- ✅ Health checks configured
- ✅ Auto-scaling enabled (HPA)
- ✅ Nginx proxy config fixed (404 errors resolved)
- ✅ Image pull policy optimized
- ✅ GitHub Actions workflow with cluster on/off control
- ✅ Volume limits set (1Gi max)

Your app is now production-ready with cost optimization! 🎉
