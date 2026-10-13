# Getting started (Kind)

## Prerequisites

- Colima/Docker with ~8 GiB RAM for two Kind clusters
- `kind`, `kubectl`, `helm`, `docker`
- Repo: `https://github.com/anilkumarsingh-pml/Nginx-Assignment-argocd.git`

## Clusters

```bash
kind create cluster --name non-prod-cluster
kind create cluster --name prod-cluster
```

## App images

```bash
for app in storefront checkout-api admin-console; do
  docker build -t "${app}:v1" "apps/${app}"
  kind load docker-image "${app}:v1" --name non-prod-cluster
  kind load docker-image "${app}:v1" --name prod-cluster
done
```

If `kind load` fails on digests:

```bash
docker save storefront:v1 | docker exec -i non-prod-cluster-control-plane ctr -n k8s.io images import -
```

## Install Argo CD

```bash
ARGOCD_VERSION=v3.5.4
for ctx in kind-non-prod-cluster kind-prod-cluster; do
  kubectl --context "$ctx" create namespace argocd --dry-run=client -o yaml \
    | kubectl --context "$ctx" apply -f -
  kubectl --context "$ctx" apply --server-side --force-conflicts -n argocd \
    -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"
done
```

Pre-load quay/ghcr images into Kind nodes if TLS/pulls fail (Zscaler). Set `imagePullPolicy: IfNotPresent` on Argo workloads including init containers when needed.

Admin password:

```bash
kubectl --context kind-non-prod-cluster -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo
```

## Apply roots (argocd-deployable)

```bash
kubectl --context kind-non-prod-cluster apply \
  -f platform/argocd-deployable/overlays/nonprod/root_app/bootstrapping-apps.yaml
kubectl --context kind-prod-cluster apply \
  -f platform/argocd-deployable/overlays/prod/root_app/bootstrapping-apps.yaml
```

Expected Applications per env: `root-*`, `platform-appprojects`, `platform-apps`, `storefront`, `checkout-api`, `admin-console`.

## UI

```bash
kubectl --context kind-non-prod-cluster -n argocd port-forward svc/argocd-server 8080:443
kubectl --context kind-prod-cluster -n argocd port-forward svc/argocd-server 8081:443
```

- Nonprod: https://localhost:8080 (`admin`)
- Prod: https://localhost:8081 (`admin`)
