# Architecture overview

```
GitHub (source of truth)
        │
        ├─ argocd/*/app-of-apps/root.yaml   ← applied once per cluster
        │         │
        │         ▼
        ├─ bootstrapping_{nonprod|prod}/    ← Helm chart
        │         │  renders:
        │         ├─ AppProject (one tenant)
        │         ├─ Namespaces
        │         └─ Application CRs (one per app)
        │                   │
        │                   ▼
        └─ charts/webapp + apps/*           ← workload Deployments/Services
```

## Clusters

| Kind cluster | Root Application | Bootstrap chart | AppProject |
|--------------|------------------|-----------------|------------|
| `non-prod-cluster` | `root-nonprod` | `bootstrapping_nonprod` | `platform-nonprod` |
| `prod-cluster` | `root-prod` | `bootstrapping_prod` | `platform-prod` |

Each cluster runs its own Argo CD. There is no shared control plane between envs (closer to real prod/nonprod separation).

## Why Helm generates Applications

Hand-maintaining one YAML per app does not scale. Listing apps in bootstrap `values.yaml` and templating `Application` objects matches how platform teams onboard services: change values → Git → sync → new Application appears.
