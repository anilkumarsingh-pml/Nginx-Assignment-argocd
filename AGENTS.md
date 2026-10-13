# AGENTS.md — working in this repo

Learning GitOps monorepo: multi-app sources, a shared Helm chart, environment bootstrap charts that **Helm-generate Argo CD Applications**, and thin App-of-Apps roots for Kind nonprod + prod.

## Repo map

| Path | Purpose |
|------|---------|
| `apps/` | Application sources (`storefront`, `checkout-api`, `admin-console`) |
| `charts/webapp/` | Shared Deployment + Service chart + per-app / env values |
| `bootstrapping_nonprod/` | Nonprod bootstrap: AppProject + namespaces + Application CRs |
| `bootstrapping_prod/` | Prod bootstrap (same pattern, prod values) |
| `argocd/nonprod/app-of-apps/` | Root Application for `non-prod-cluster` |
| `argocd/prod/app-of-apps/` | Root Application for `prod-cluster` |
| `docs/` | Architecture, onboarding, ADRs |
| `scripts/` | Lab helpers (image transfer, cluster bootstrap) |

## Kind clusters

| Cluster | Role |
|---------|------|
| `non-prod-cluster` | Nonprod Argo CD + apps |
| `prod-cluster` | Prod Argo CD + apps |

Do not put this project's workloads on an unrelated `dev-cluster`.

## Source of truth

- Git is the source of truth. Change charts / bootstrap values / roots, push, let Argo sync.
- Do not treat `kubectl edit` as permanent (`selfHeal` reverts drift).

## Do

- Onboard a new app by adding `apps/<name>/`, a `values-<name>.yaml` under `charts/webapp/`, and an entry under `applications:` in **both** bootstrap `values.yaml` files.
- Run `helm lint` / `helm template` on bootstrap + webapp charts before pushing.
- Load images into each Kind cluster (`kind load` or `scripts/transfer-images.sh`); there is no registry in this lab.
- Bootstrap **both** env clusters when demonstrating prod parity.

## Do not

- Commit secrets, tokens, kubeconfigs, or `.certs/`.
- Hand-write one Application YAML per app under `argocd/*/applications/` — bootstrap Helm owns that.
- Point Argo CD at a different `repoURL` without updating roots + both bootstrap values consistently.

## Bootstrap order

1. Push to `https://github.com/anilkumarsingh-pml/Nginx-Assignment-argocd.git`
2. Build app images; `kind load` into `non-prod-cluster` and `prod-cluster`
3. Install Argo CD in both clusters (load quay/ghcr images if pulls fail)
4. `kubectl --context kind-non-prod-cluster apply -f argocd/nonprod/app-of-apps/root.yaml`
5. `kubectl --context kind-prod-cluster apply -f argocd/prod/app-of-apps/root.yaml`
6. Port-forward Argo CD and verify Applications Synced/Healthy

Details: [docs/onboarding/local-kind-gitops.md](docs/onboarding/local-kind-gitops.md)

## Agent behavior

Explain why each GitOps/Helm piece exists. Prefer small, reviewable changes. Keep app HTML/behavior stable unless asked to change it.
