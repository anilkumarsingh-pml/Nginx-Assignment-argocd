# Platform GitOps lab (Argo CD + Helm on Kind)

Multi-app monorepo for production-style GitOps on two Kind clusters:

- **Clusters**: `non-prod-cluster` and `prod-cluster` (each runs its own Argo CD)
- **One tenant per env**: AppProjects `platform-nonprod` / `platform-prod`
- **Bootstrap Helm charts** generate Argo CD `Application` CRs from values
- **Shared chart**: `charts/webapp` with per-app and per-env overlays

Remote: `https://github.com/anilkumarsingh-pml/Nginx-Assignment-argocd.git`

## Apps

Static nginx demo pages (one Deployment + Service each):

| App | Image | Namespace | Nonprod replicas | Prod replicas |
|-----|-------|-----------|------------------|---------------|
| storefront | `storefront:v1` | storefront | 1 | 2 |
| checkout-api | `checkout-api:v1` | checkout-api | 1 | 2 |
| admin-console | `admin-console:v1` | admin-console | 1 | 2 |

## Quick start

```bash
# 1) Clusters
kind create cluster --name non-prod-cluster
kind create cluster --name prod-cluster

# 2) Build + load app images into BOTH clusters
for app in storefront checkout-api admin-console; do
  docker build -t "${app}:v1" "apps/${app}"
  kind load docker-image "${app}:v1" --name non-prod-cluster
  kind load docker-image "${app}:v1" --name prod-cluster
done

# 3) Install Argo CD (see docs/onboarding if image pulls fail)
kubectl create namespace argocd --context kind-non-prod-cluster --dry-run=client -o yaml \
  | kubectl --context kind-non-prod-cluster apply -f -
kubectl --context kind-non-prod-cluster apply --server-side --force-conflicts -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.4/manifests/install.yaml

kubectl create namespace argocd --context kind-prod-cluster --dry-run=client -o yaml \
  | kubectl --context kind-prod-cluster apply -f -
kubectl --context kind-prod-cluster apply --server-side --force-conflicts -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.4/manifests/install.yaml

# 4) Push this repo, then apply roots
kubectl --context kind-non-prod-cluster apply -f argocd/nonprod/app-of-apps/root.yaml
kubectl --context kind-prod-cluster apply -f argocd/prod/app-of-apps/root.yaml

# 5) Argo CD UIs (keep these terminals open)
kubectl --context kind-non-prod-cluster -n argocd port-forward svc/argocd-server 8080:443
kubectl --context kind-prod-cluster -n argocd port-forward svc/argocd-server 8081:443
```

- Nonprod UI: https://localhost:8080  
- Prod UI: https://localhost:8081  
- Login: `admin` + password from `argocd-initial-admin-secret` (see onboarding doc)

Full steps: [docs/onboarding/local-kind-gitops.md](docs/onboarding/local-kind-gitops.md)  
Architecture: [docs/architecture/overview.md](docs/architecture/overview.md)

## Onboard another app

1. Add `apps/<name>/` (Dockerfile + content)
2. Add `charts/webapp/values-<name>.yaml`
3. Append an entry under `applications:` in **both** `bootstrapping_nonprod/values.yaml` and `bootstrapping_prod/values.yaml`
4. Build and load the image into both Kind clusters; push Git; Argo creates/syncs the new Application
