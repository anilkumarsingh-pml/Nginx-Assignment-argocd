# AGENTS.md — working in this repo

Learning GitOps monorepo shaped like PML `pml-argocd`: shared `docs/`, one tenant folder `platform/` (analogue of `mfv2/`), Helm-generated Applications, dual Kind clusters.

## Repo map

| Path | Purpose |
|------|---------|
| `apps/` | Demo app sources (stand-in for separate product repos) |
| `platform/` | **The tenant** — deployable roots, bootstrap, env trees |
| `platform/argocd-deployable/` | Apply-once root Applications (nonprod/prod overlays) |
| `platform/bootstrapping_nonprod/` | Root Helm: generates layer Applications |
| `platform/bootstrapping_prod/` | Same for prod |
| `platform/nonprod/project-platform/` | AppProjects + apps App-of-Apps (nonprod) |
| `platform/prod/project-platform/` | AppProjects + apps App-of-Apps + `app-helm-chart/webapp` |
| `docs/` | Architecture, onboarding, ADRs (`architecture/decisions/`) |

## Kind clusters

| Cluster | Root apply |
|---------|------------|
| `non-prod-cluster` | `platform/argocd-deployable/overlays/nonprod/root_app/bootstrapping-apps.yaml` |
| `prod-cluster` | `platform/argocd-deployable/overlays/prod/root_app/bootstrapping-apps.yaml` |

Do not put this project's workloads on an unrelated `dev-cluster`.

## Source of truth

- Git is the source of truth. Change charts / bootstrap / app-of-apps values, push, let Argo sync.
- Do not treat `kubectl edit` as permanent (`selfHeal` reverts drift).

## Do

- Onboard a new app: add `apps/<name>/`, `values-<name>.yaml` under `app-helm-chart/webapp`, and an entry under `applications:` in **both** `platform/*/project-platform/app-of-apps/values.yaml` files.
- Run `helm lint` / `helm template` on bootstrap + app-of-apps + webapp charts before pushing.
- Load images into each Kind cluster (`kind load` or `docker save \| ctr import`). No registry in this lab.
- Bootstrap **both** env clusters for prod parity.

## Do not

- Commit secrets, tokens, kubeconfigs, or `.certs/`.
- Hand-write workload Application YAMLs — `app-of-apps` Helm owns those.
- Point roots at a different `repoURL` without updating deployable + bootstrap + app-of-apps values consistently.

## Bootstrap order

1. Push to `https://github.com/anilkumarsingh-pml/Nginx-Assignment-argocd.git`
2. Build/load app images into both Kind clusters
3. Install Argo CD on both clusters
4. Apply nonprod + prod roots from `platform/argocd-deployable/overlays/*/root_app/`
5. Verify Applications Synced/Healthy; port-forward UIs

Details: [docs/onboarding/getting-started.md](docs/onboarding/getting-started.md)

## Agent behavior

Explain why each GitOps/Helm layer exists (PML parity). Prefer small, reviewable changes. Keep app HTML stable unless asked to change it.
