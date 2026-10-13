# Docs

Learning documentation for the NGINX + Helm + Argo CD Kind lab.

| Doc | What you learn |
|-----|----------------|
| [architecture/overview.md](architecture/overview.md) | How app, Helm, and Argo CD fit together |
| [onboarding/local-kind-gitops.md](onboarding/local-kind-gitops.md) | Step-by-step local deploy |
| [adr/0001-gitops-with-argocd-and-helm.md](adr/0001-gitops-with-argocd-and-helm.md) | Why GitOps + Helm |
| [adr/0002-app-of-apps-pattern.md](adr/0002-app-of-apps-pattern.md) | Why App-of-Apps |
| [adr/0003-environment-bootstrap-charts.md](adr/0003-environment-bootstrap-charts.md) | Why `bootstrapping_nonprod` / `_prod` |

Start with the architecture overview, then follow onboarding on your Kind cluster.
