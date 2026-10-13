# argocd-deployable

Apply-once entrypoints for nonprod and prod Kind clusters. Roots only; Argo CD is installed from upstream manifests (see docs onboarding). Full PML installs also ship Kustomize overlays for HA Argo CD — not required here.

| Overlay | Cluster | Root Application path |
|---------|---------|------------------------|
| `overlays/nonprod/root_app/` | `non-prod-cluster` | → `platform/bootstrapping_nonprod` |
| `overlays/prod/root_app/` | `prod-cluster` | → `platform/bootstrapping_prod` |
