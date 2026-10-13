#!/usr/bin/env bash
# Load Argo CD dependency images into a Kind cluster (no registry).
set -euo pipefail

CLUSTER="${1:?usage: $0 <kind-cluster-name>}"

IMAGES=(
  "quay.io/argoproj/argocd:v3.5.4"
  "ghcr.io/dexidp/dex:v2.45.1"
  "public.ecr.aws/docker/library/redis:8.2.3-alpine"
  "haproxy:3.0.8-alpine"
)

NODE="${CLUSTER}-control-plane"
for img in "${IMAGES[@]}"; do
  echo "==> ctr import $img -> $CLUSTER"
  # kind load can fail on multi-arch digests; docker save | ctr import is reliable.
  docker save "$img" | docker exec -i "$NODE" ctr -n k8s.io images import -
done
