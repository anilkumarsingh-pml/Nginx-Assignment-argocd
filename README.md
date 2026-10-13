# Platform GitOps (Argo CD + Helm on Kind)

Single-tenant GitOps monorepo structured like `pml-argocd` / `mfv2/`:

```
docs/                         # shared docs
apps/                         # application sources
platform/                     # ← THE TENANT
  argocd-deployable/          # apply-once roots
  bootstrapping_{nonprod,prod}/
  nonprod|prod/project-platform/
    infra-manifests/app-projects/
    app-of-apps/              # Helm → workload Applications
    app-helm-chart/webapp/    # (under prod) shared chart
```

Remote: `https://github.com/anilkumarsingh-pml/Nginx-Assignment-argocd.git`

## Apps

| App | Image | Nonprod replicas | Prod replicas |
|-----|-------|------------------|---------------|
| storefront | `storefront:v1` | 1 | 2 |
| checkout-api | `checkout-api:v1` | 1 | 2 |
| admin-console | `admin-console:v1` | 1 | 2 |

## Quick start

```bash
# Images
for app in storefront checkout-api admin-console; do
  docker build -t "${app}:v1" "apps/${app}"
  kind load docker-image "${app}:v1" --name non-prod-cluster
  kind load docker-image "${app}:v1" --name prod-cluster
done

# Roots (Argo CD already installed)
kubectl --context kind-non-prod-cluster apply \
  -f platform/argocd-deployable/overlays/nonprod/root_app/bootstrapping-apps.yaml
kubectl --context kind-prod-cluster apply \
  -f platform/argocd-deployable/overlays/prod/root_app/bootstrapping-apps.yaml

# UIs
kubectl --context kind-non-prod-cluster -n argocd port-forward svc/argocd-server 8080:443
kubectl --context kind-prod-cluster -n argocd port-forward svc/argocd-server 8081:443
```

Full guide: [docs/onboarding/getting-started.md](docs/onboarding/getting-started.md)  
Architecture: [docs/architecture/overview.md](docs/architecture/overview.md)  
Tenant README: [platform/README.md](platform/README.md)

## Onboard another app

1. `apps/<name>/` + Dockerfile
2. `platform/prod/project-platform/app-helm-chart/webapp/values-<name>.yaml`
3. Entry in both `platform/{nonprod,prod}/project-platform/app-of-apps/values.yaml` → `applications:`
4. Build/load image; push Git
