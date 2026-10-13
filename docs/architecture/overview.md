# Architecture overview

## Layout (PML-shaped)

```
GitHub
├── docs/                          # shared
├── apps/                          # demo sources (≠ product repos, but same role)
└── platform/                      # tenant (≈ mfv2/)
    ├── argocd-deployable/overlays/{nonprod,prod}/root_app/
    ├── bootstrapping_{nonprod,prod}/    # deployments[] → layer Applications
    ├── nonprod/project-platform/
    │   ├── infra-manifests/app-projects/
    │   └── app-of-apps/                 # applications[] → workload Applications
    └── prod/project-platform/
        ├── infra-manifests/app-projects/
        ├── app-of-apps/
        └── app-helm-chart/webapp/
```

## Sync chain

```
root-nonprod / root-prod
        │
        ▼
bootstrapping_*  (Helm)
        │  deployments[]
        ├─ platform-appprojects  → AppProject YAML
        └─ platform-apps         → app-of-apps Helm chart
                │  applications[]
                ├─ storefront
                ├─ checkout-api
                └─ admin-console  → webapp chart
```

## Clusters

| Kind cluster | Root YAML | Bootstrap | AppProject |
|--------------|-----------|-----------|------------|
| `non-prod-cluster` | `argocd-deployable/overlays/nonprod/...` | `bootstrapping_nonprod` | `platform-nonprod` |
| `prod-cluster` | `argocd-deployable/overlays/prod/...` | `bootstrapping_prod` | `platform-prod` |

Each cluster runs its own Argo CD (two UIs when port-forwarded).

## vs PML `mfv2/`

| PML | This lab |
|-----|----------|
| `mfv2/` tenant | `platform/` |
| Full `argocd-deployable` Kustomize install | Roots only; Argo installed from upstream |
| infra-app-of-apps + large infra-manifests | AppProjects only under infra-manifests |
| prod-app-of-apps + Kafka charts | app-of-apps → three webapps |
| Many AppProjects / cross-repos | One AppProject per env, one repo |
