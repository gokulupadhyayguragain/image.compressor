#!/usr/bin/env bash
set -euo pipefail
# Single script to create (up) or delete (down) an EKS cluster via eksctl.
# Designed to be used interactively or in CI (non-interactive mode when CI=true).
# Usage:
#   ./scripts/eksctl.sh up [cluster-name] [region] [node-type]
#   ./scripts/eksctl.sh down [cluster-name] [region]

CMD=${1:-}
if [ -z "$CMD" ]; then
  echo "Usage: $0 up|down [cluster-name] [region] [node-type]"
  exit 2
fi

CLUSTER_NAME=${2:-$(grep -E '^EKS_CLUSTER_NAME=' .env 2>/dev/null | cut -d '=' -f2 || echo "image-compressor-cluster")}
REGION=${3:-$(grep -E '^AWS_REGION=' .env 2>/dev/null | cut -d '=' -f2 || echo "ap-southeast-2")}
NODE_TYPE=${4:-t3.small}

if [ "$CMD" = "up" ]; then
  echo "Preparing to create EKS cluster: name=$CLUSTER_NAME region=$REGION node_type=$NODE_TYPE"
  if [ -z "${CI:-}" ]; then
    read -p "Proceed to create cluster? (y/N) " yn
    case "$yn" in
      [Yy]*) ;;
      *) echo "Aborted."; exit 1 ;;
    esac
  else
    echo "CI mode detected (CI=true). Creating cluster non-interactively."
  fi

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
  exit 0
fi

if [ "$CMD" = "down" ]; then
  echo "Preparing to delete EKS cluster: name=$CLUSTER_NAME region=$REGION"
  if [ -z "${CI:-}" ]; then
    read -p "Proceed to delete cluster? This will remove all resources. (y/N) " yn
    case "$yn" in
      [Yy]*) ;;
      *) echo "Aborted."; exit 1 ;;
    esac
  else
    echo "CI mode detected (CI=true). Deleting cluster non-interactively."
  fi

  eksctl delete cluster --name "$CLUSTER_NAME" --region "$REGION"
  echo "Cluster delete command submitted."
  exit 0
fi

echo "Unknown command: $CMD"
echo "Usage: $0 up|down [cluster-name] [region] [node-type]"
exit 2
