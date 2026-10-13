#!/usr/bin/env bash
# Copy container images from one Kind node to another via containerd export/import.
set -euo pipefail

SRC_CLUSTER="${1:?usage: $0 <src-cluster> <dst-cluster> <image> [<image>...]}"
DST_CLUSTER="${2:?}"
shift 2

SRC_NODE="${SRC_CLUSTER}-control-plane"
DST_NODE="${DST_CLUSTER}-control-plane"

for IMAGE in "$@"; do
  echo "==> Transfer $IMAGE : $SRC_CLUSTER -> $DST_CLUSTER"
  docker exec "$SRC_NODE" ctr -n k8s.io images export - "$IMAGE" \
    | docker exec -i "$DST_NODE" ctr -n k8s.io images import -
  echo "    OK"
done
