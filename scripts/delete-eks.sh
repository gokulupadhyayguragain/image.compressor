#!/usr/bin/env bash
set -euo pipefail
# Delete an EKS cluster created with eksctl
# Usage: ./scripts/delete-eks.sh [cluster-name] [region]

CLUSTER_NAME=${1:-$(grep -E '^EKS_CLUSTER_NAME=' .env 2>/dev/null | cut -d '=' -f2 || echo "image-compressor-cluster")}
REGION=${2:-$(grep -E '^AWS_REGION=' .env 2>/dev/null | cut -d '=' -f2 || echo "ap-southeast-2")}

echo "Deleting EKS cluster '$CLUSTER_NAME' in region $REGION"
read -p "Proceed? (y/N) " yn
case "$yn" in
  [Yy]*) true ;;
  *) echo "Aborted."; exit 1 ;;
esac

eksctl delete cluster --name "$CLUSTER_NAME" --region "$REGION"

echo "Cluster delete command submitted. Verify with 'eksctl get cluster --region $REGION'"
