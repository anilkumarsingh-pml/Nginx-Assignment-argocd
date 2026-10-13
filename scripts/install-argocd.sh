#!/usr/bin/env bash
# Install Argo CD into an existing Kind cluster context.
set -euo pipefail

CONTEXT="${1:?usage: $0 <kubectl-context>}"
VERSION="${ARGOCD_VERSION:-v3.5.4}"

kubectl --context "$CONTEXT" create namespace argocd --dry-run=client -o yaml | kubectl --context "$CONTEXT" apply -f -
# Server-side apply avoids ApplicationSet CRD annotation size limits on some kubectl/API versions.
kubectl --context "$CONTEXT" apply --server-side --force-conflicts -n argocd \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/${VERSION}/manifests/install.yaml"

# Zscaler / offline Kind: avoid Always pulls against quay/ghcr.
kubectl --context "$CONTEXT" -n argocd get deploy,sts -o name | while read -r obj; do
  kubectl --context "$CONTEXT" -n argocd get "$obj" -o json | python3 -c '
import json,sys
d=json.load(sys.stdin)
pod=d["spec"]["template"]["spec"]
for key in ("initContainers","containers"):
  for c in pod.get(key) or []:
    c["imagePullPolicy"]="IfNotPresent"
print(json.dumps({"spec":{"template":{"spec":{
  "initContainers": pod.get("initContainers"),
  "containers": pod.get("containers"),
}}}}))
' | kubectl --context "$CONTEXT" -n argocd patch "$obj" --type strategic --patch-file /dev/stdin >/dev/null
done

echo "Waiting for argocd-server..."
kubectl --context "$CONTEXT" -n argocd rollout status deploy/argocd-server --timeout=300s
kubectl --context "$CONTEXT" -n argocd get pods
