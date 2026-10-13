# AGENTS.md — working in this repo

This repository is a **learning GitOps monorepo** for a DevOps intern: NGINX app source, Helm charts (app + environment bootstrap), and Argo CD manifests live together so you can see the full path from code → chart → Git → cluster.

## Repo map

| Path | Purpose |
|------|---------|
| `app/` | Application source (HTML + Dockerfile) |
| `charts/nginx-app/` | Application Helm chart (Deployment + Service) |
| `bootstrapping_nonprod/` | Nonprod bootstrap Helm chart (AppProject + Namespace) |
| `bootstrapping_prod/` | Prod bootstrap Helm chart (learning stub / env parity) |
| `argocd/nonprod/` | Nonprod App-of-Apps + Applications (Kind lab) |
| `argocd/prod/` | Prod App-of-Apps + Applications (do not apply on Kind by default) |
| `docs/` | Architecture, onboarding, ADRs |
| `REPORT.md` | Earlier Kind assignment write-up (history) |

## Source of truth

- **Git is the source of truth** for desired cluster state (charts + Argo manifests).
- Prefer changing charts or `argocd/` and pushing, then let Argo CD sync.
- Do **not** treat `kubectl edit` / imperative cluster tweaks as permanent configuration (`selfHeal` will revert drift).

## Do

- Run `helm template` / `helm lint` locally before pushing chart changes (when Helm is installed).
- Use `values-nonprod.yaml` / `values-prod.yaml` for env overrides; keep templates generic.
- Load images into Kind with `kind load docker-image` (no registry in this lab).
- Document decisions in `docs/adr/` when you change approach.
- On Kind, bootstrap **nonprod** only unless a human asks for prod parity testing.

## Do not

- Commit secrets, tokens, kubeconfigs, or `.certs/`.
- Reinstall or modify the Argo CD installation in namespace `argocd` unless a human explicitly asks.
- Invent health probes, env vars, or registry credentials that the app does not use.
- Point Argo CD at a different `repoURL` without updating all Application manifests consistently.
- Apply `argocd/prod/app-of-apps/root.yaml` on the learning cluster without explaining it will create a second environment.

## Bootstrap order (humans + agents)

1. Push this repo to GitHub: `https://github.com/anilkumarsingh-pml/Nginx-Assignment-argocd.git`
2. Build and `kind load` `nginx-app:v1` into `dev-cluster`
3. `kubectl apply -f argocd/nonprod/app-of-apps/root.yaml`
4. Verify Applications Synced/Healthy (`bootstrapping-nonprod`, plus workload apps) and port-forward a Service

Details: [docs/onboarding/local-kind-gitops.md](docs/onboarding/local-kind-gitops.md)

## Agent behavior

When helping in this repo, explain **why** each GitOps/Helm piece exists (learning goal). Prefer small, reviewable changes. Keep the NGINX app behavior identical unless asked to change it.
