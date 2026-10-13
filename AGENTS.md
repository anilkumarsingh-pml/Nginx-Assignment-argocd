# AGENTS.md — working in this repo

This repository is a **learning GitOps monorepo** for a DevOps intern: NGINX app source, Helm chart, and Argo CD manifests live together so you can see the full path from code → chart → Git → cluster.

## Repo map

| Path | Purpose |
|------|---------|
| `app/` | Application source (HTML + Dockerfile) |
| `charts/nginx-app/` | Helm chart (Kubernetes templates + values) |
| `argocd/nonprod/` | Argo CD AppProject, Applications, App-of-Apps root |
| `docs/` | Architecture, onboarding, ADRs |
| `REPORT.md` | Earlier Kind assignment write-up (history) |

## Source of truth

- **Git is the source of truth** for desired cluster state (chart + Argo manifests).
- Prefer changing `charts/` or `argocd/` and pushing, then let Argo CD sync.
- Do **not** treat `kubectl edit` / imperative cluster tweaks as permanent configuration (`selfHeal` will revert drift).

## Do

- Run `helm template` / `helm lint` locally before pushing chart changes (when Helm is installed).
- Use `values-nonprod.yaml` for Kind/local overrides; keep templates generic.
- Load images into Kind with `kind load docker-image` (no registry in this lab).
- Document decisions in `docs/adr/` when you change approach.

## Do not

- Commit secrets, tokens, kubeconfigs, or `.certs/`.
- Reinstall or modify the Argo CD installation in namespace `argocd` unless a human explicitly asks.
- Invent health probes, env vars, or registry credentials that the app does not use.
- Point Argo CD at a different `repoURL` without updating all Application manifests consistently.

## Bootstrap order (humans + agents)

1. Push this repo to GitHub: `https://github.com/anilkumarsingh-pml/Nginx-Assignment-argocd.git`
2. Build and `kind load` `nginx-app:v1` into `dev-cluster`
3. `kubectl apply -f argocd/nonprod/app-of-apps/root.yaml`
4. Verify Applications Synced/Healthy and port-forward the Service

Details: [docs/onboarding/local-kind-gitops.md](docs/onboarding/local-kind-gitops.md)

## Agent behavior

When helping in this repo, explain **why** each GitOps/Helm piece exists (learning goal). Prefer small, reviewable changes. Keep the NGINX app behavior identical unless asked to change it.
