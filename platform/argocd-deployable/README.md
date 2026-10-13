# argocd-deployable

Apply-once entrypoints for Kind lab clusters (simplified vs PML’s full Kustomize Argo CD install).

| Overlay | Cluster | Root Application path |
|---------|---------|------------------------|
| `overlays/nonprod/root_app/` | `non-prod-cluster` | → `platform/bootstrapping_nonprod` |
| `overlays/prod/root_app/` | `prod-cluster` | → `platform/bootstrapping_prod` |

Argo CD itself is installed from upstream manifests (see docs onboarding). This folder owns the **root App-of-Apps** YAMLs.
