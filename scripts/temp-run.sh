#!/usr/bin/env bash
set -euo pipefail
# Ephemeral local test using k3d: create cluster, build images, deploy manifests,
# port-forward frontend for 5 minutes, then tear down.
# Requirements: Docker, k3d, kubectl

CLUSTER_NAME=${1:-temp-cluster}
RUN_MINUTES=${2:-5}

echo "Creating k3d cluster '$CLUSTER_NAME'"
k3d cluster create "$CLUSTER_NAME" --agents 1

echo "Building backend image"
docker build -t backend-local:latest -f docker/backend.dockerfile backend
k3d image import backend-local:latest -c "$CLUSTER_NAME"

echo "Building frontend image"
docker build -t frontend-local:latest -f docker/frontend.dockerfile .
k3d image import frontend-local:latest -c "$CLUSTER_NAME"

echo "Applying k8s manifests"
kubectl apply -f k8s/deployment.yaml

echo "Patching deployments to use local images"
kubectl -n default set image deployment/gocools-backend backend=backend-local:latest --record || true
kubectl -n default set image deployment/gocools-frontend frontend=frontend-local:latest --record || true

echo "Waiting for deployments to be ready (30s)"
sleep 30

echo "Starting port-forward for frontend on localhost:8080"
kubectl port-forward svc/gocools-frontend 8080:80 & pfpid=$!

echo "App available at http://localhost:8080 for $RUN_MINUTES minute(s)"
sleep $((RUN_MINUTES * 60))

echo "Stopping port-forward and deleting cluster"
kill "$pfpid" || true
k3d cluster delete "$CLUSTER_NAME"

echo "Done."
