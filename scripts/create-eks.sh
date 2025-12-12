#!/usr/bin/env bash
set -euo pipefail
# Create a small EKS cluster using eksctl. Requires eksctl, aws cli and sufficient IAM permissions.
# Usage: ./scripts/create-eks.sh [cluster-name] [region] [node-type]

CLUSTER_NAME=${1:-$(grep -E '^EKS_CLUSTER_NAME=' .env 2>/dev/null | cut -d '=' -f2 || echo "image-compressor-cluster")}
REGION=${2:-$(grep -E '^AWS_REGION=' .env 2>/dev/null | cut -d '=' -f2 || echo "ap-southeast-2")}
NODE_TYPE=${3:-t3.small}

echo "Creating EKS cluster '$CLUSTER_NAME' in region $REGION with node type $NODE_TYPE"
echo "This will incur AWS charges (control plane + node instances)."
read -p "Proceed? (y/N) " yn
case "$yn" in
  [Yy]*) true ;;
  *) echo "Aborted."; exit 1 ;;
esac

eksctl create cluster \
  --name "$CLUSTER_NAME" \
  --region "$REGION" \
  --nodegroup-name small-nodes \
  --node-type "$NODE_TYPE" \
  --nodes 1 \
  --nodes-min 1 \
  --nodes-max 1 \
  --managed

echo "Cluster create command submitted. Use 'eksctl get cluster --region $REGION' to check status."
