# Architecture overview

## Flow

```
GitHub (source of truth)
        │
        ├─ argocd/{nonprod|prod}/app-of-apps/root.yaml   ← applied once per cluster
        │         │
        │         ▼
        ├─ bootstrapping_{nonprod|prod}/                 ← Helm chart
        │         │  renders:
        │         ├─ AppProject (one tenant)
        │         ├─ Namespaces
        │         └─ Application CRs (one per app in values)
        │                   │
        │                   ▼
        └─ charts/webapp + apps/*                        ← Deployments + Services
```

## Clusters and Argo CD

| Kind cluster | Root Application | Bootstrap chart | AppProject | Typical UI port-forward |
|--------------|------------------|-----------------|------------|-------------------------|
| `non-prod-cluster` | `root-nonprod` | `bootstrapping_nonprod` | `platform-nonprod` | https://localhost:8080 |
| `prod-cluster` | `root-prod` | `bootstrapping_prod` | `platform-prod` | https://localhost:8081 |

Each cluster runs **its own Argo CD**. There is no shared control plane between envs. That is intentional: closer to real nonprod/prod separation than one Argo CD managing both.

Two UIs exist because there are two independent Argo CD installations — not because one cluster exposes two dashboards.

## Applications (workloads)

| App | Role (demo) | Chart overlays |
|-----|-------------|----------------|
| `storefront` | Customer-facing catalog page | `values-storefront.yaml` + env values |
| `checkout-api` | Checkout / payments surface page | `values-checkout-api.yaml` + env values |
| `admin-console` | Internal ops portal page | `values-admin-console.yaml` + env values |

All three share `charts/webapp` (Deployment + Service). Content lives under `apps/<name>/`. Env scale differs: nonprod `replicaCount: 1`, prod `replicaCount: 2`.

## Why Helm generates Applications

Hand-maintaining one Application YAML per app does not scale and drifts between envs. Listing apps under `applications:` in bootstrap `values.yaml` and templating `Application` objects matches how platform teams onboard services: change values → push Git → Argo syncs → new Application appears.

Root Applications must not recurse into themselves; they target only the bootstrap chart path.

## Related ADRs

- [0001 GitOps with Argo CD and Helm](../adr/0001-gitops-with-argocd-and-helm.md)
- [0002 App-of-Apps pattern](../adr/0002-app-of-apps-pattern.md)
- [0003 Environment bootstrap charts](../adr/0003-environment-bootstrap-charts.md)
- [0004 Helm-generated Applications](../adr/0004-helm-generated-applications.md)
