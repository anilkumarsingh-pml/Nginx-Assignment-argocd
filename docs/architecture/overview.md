# Architecture overview

## Goal

Deploy the NGINX learning app to a local Kind cluster (`dev-cluster`) using **Helm** (package the app) and **Argo CD** (sync Git → cluster), without changing how Argo CD itself is installed.

## Components

```text
GitHub (Nginx-Assignment-argocd)
        │
        ▼
┌───────────────────┐     syncs      ┌─────────────────────────────┐
│ nginx-gitops-root │ ─────────────► │ Applications:              │
│ (App-of-Apps)     │                │  bootstrapping-nonprod     │
└───────────────────┘                │  nginx-app                 │
                                     └─────────┬───────────────────┘
                    wave 0                     │            wave 1
                                               ▼
                          ┌────────────────────────┐   ┌────────────────────┐
                          │ bootstrapping_nonprod  │   │ charts/nginx-app   │
                          │ → AppProject           │   │ → Deploy + Service │
                          │ → Namespace nginx-app  │   │ namespace nginx-app│
                          └────────────────────────┘   └────────────────────┘
```

1. **`app/`** — immutable container image content (HTML served by NGINX).
2. **`bootstrapping_nonprod/`** (and stub `bootstrapping_prod/`) — environment Helm charts (AppProject + Namespace) that run **before** app charts.
3. **`charts/nginx-app`** — application Helm chart (Deployment + Service).
4. **`argocd/nonprod`** — App-of-Apps + Applications for Kind; **`argocd/prod`** mirrors the pattern for learning.
5. **Kind node** — must already have `nginx-app:v1` via `kind load` (`IfNotPresent`).

## Why this shape (inspired by larger platforms)

Production repos (e.g. multi-service GitOps layouts) often separate:

- Helm/charts or deployable manifests
- Environment folders (`nonprod` / `prod`)
- App-of-Apps to bootstrap many Applications
- AppProjects for multi-team guardrails

This lab keeps **one app** and **one environment (`nonprod`)** so you learn the same patterns without the noise of dozens of microservices.

## Data flow for a change

1. Edit `charts/nginx-app/values-nonprod.yaml` (e.g. `replicaCount: 3`).
2. Commit and push to GitHub.
3. Argo CD detects Git change → syncs Helm release.
4. Deployment rolls out; Service keeps a stable entrypoint.
