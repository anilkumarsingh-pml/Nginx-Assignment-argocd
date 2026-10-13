# Local Kind GitOps onboarding

## Prerequisites

- Colima (or Docker Desktop) with enough RAM for **two** Kind clusters (~8 GiB recommended)
- `kind`, `kubectl`, `helm`, `docker`
- This repo pushed to `https://github.com/anilkumarsingh-pml/Nginx-Assignment-argocd.git`

## Clusters

```bash
kind create cluster --name non-prod-cluster
kind create cluster --name prod-cluster
```

If a third cluster fails to start while others are running, stop one control-plane container, create the new cluster, then start the stopped node again.

## Images (no registry)

```bash
for app in storefront checkout-api admin-console; do
  docker build -t ${app}:v1 "apps/${app}"
  kind load docker-image ${app}:v1 --name non-prod-cluster
  kind load docker-image ${app}:v1 --name prod-cluster
done

# Argo CD images (load into both if quay/ghcr pulls fail inside Kind)
./scripts/load-argocd-images.sh non-prod-cluster
./scripts/load-argocd-images.sh prod-cluster
```

To copy an image already present on one Kind node to another:

```bash
./scripts/transfer-images.sh non-prod-cluster prod-cluster storefront:v1
```

## Install Argo CD

```bash
./scripts/install-argocd.sh kind-non-prod-cluster
./scripts/install-argocd.sh kind-prod-cluster
```

Initial admin password:

```bash
kubectl --context kind-non-prod-cluster -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo
```

## Bootstrap apps

```bash
kubectl --context kind-non-prod-cluster apply -f argocd/nonprod/app-of-apps/root.yaml
kubectl --context kind-prod-cluster apply -f argocd/prod/app-of-apps/root.yaml
```

Watch:

```bash
kubectl --context kind-non-prod-cluster -n argocd get applications
kubectl --context kind-prod-cluster -n argocd get applications
```

## Argo CD UI

```bash
kubectl --context kind-non-prod-cluster -n argocd port-forward svc/argocd-server 8080:443
# open https://localhost:8080  (user: admin)
```

Use another local port (e.g. `8081`) for prod simultaneously.
