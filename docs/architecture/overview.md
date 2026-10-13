# Architecture overview

## Goal

Deploy the NGINX learning app to a local Kind cluster (`dev-cluster`) using **Helm** (package the app) and **Argo CD** (sync Git → cluster), without changing how Argo CD itself is installed.

## Components

```text
GitHub (Nginx-Assignment-argocd)
        │
        ▼
┌───────────────────┐     syncs      ┌────────────────────┐
│ nginx-gitops-root │ ─────────────► │ AppProject +       │
│ (App-of-Apps)     │                │ Application YAML   │
└───────────────────┘                └─────────┬──────────┘
                                               │ renders Helm
                                               ▼
                                     ┌────────────────────┐
                                     │ charts/nginx-app   │
                                     │ → Deploy + Service │
                                     │ namespace nginx-app│
                                     └────────────────────┘
```

1. **`app/`** — immutable container image content (HTML served by NGINX).
2. **`charts/nginx-app`** — Helm chart turns values into Deployment + Service YAML.
3. **`argocd/nonprod`** — declares *what* Argo should manage (project + apps).
4. **Kind node** — must already have `nginx-app:v1` via `kind load` (`IfNotPresent`).

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
