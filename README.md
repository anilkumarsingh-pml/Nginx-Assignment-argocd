# Platform GitOps lab (Argo CD + Helm on Kind)

Multi-app monorepo demonstrating production-style GitOps:

- **Two Kind clusters**: `non-prod-cluster` and `prod-cluster`
- **One tenant** per env (`platform-nonprod` / `platform-prod` AppProjects)
- **Bootstrap Helm charts** generate Argo CD `Application` objects for every app
- Shared **`charts/webapp`** chart with per-app and per-env values

## Apps

| App | Image | Namespace |
|-----|-------|-----------|
| storefront | `storefront:v1` | storefront |
| checkout-api | `checkout-api:v1` | checkout-api |
| admin-console | `admin-console:v1` | admin-console |

## Quick start

```bash
# 1) Clusters (if needed)
kind create cluster --name non-prod-cluster
kind create cluster --name prod-cluster

# 2) Build + load images into BOTH clusters
for app in storefront checkout-api admin-console; do
  docker build -t ${app}:v1 apps/${app}
  kind load docker-image ${app}:v1 --name non-prod-cluster
  kind load docker-image ${app}:v1 --name prod-cluster
done

# 3) Install Argo CD (after loading images if registry pulls fail)
./scripts/install-argocd.sh kind-non-prod-cluster
./scripts/install-argocd.sh kind-prod-cluster

# 4) Push this repo, then apply roots
kubectl --context kind-non-prod-cluster apply -f argocd/nonprod/app-of-apps/root.yaml
kubectl --context kind-prod-cluster apply -f argocd/prod/app-of-apps/root.yaml

# 5) UI (example: nonprod)
kubectl --context kind-non-prod-cluster -n argocd port-forward svc/argocd-server 8080:443
```

See [docs/onboarding/local-kind-gitops.md](docs/onboarding/local-kind-gitops.md).

## Onboard another app

1. Add `apps/<name>/` (Dockerfile + content)
2. Add `charts/webapp/values-<name>.yaml`
3. Append an entry to `applications:` in `bootstrapping_nonprod/values.yaml` and `bootstrapping_prod/values.yaml`
4. Build/load the image; push Git; Argo syncs new Application CRs automatically
