# NGINX Assignment — Argo CD + Helm (Kind)

Learning GitOps repo for the DevOps training track:

1. Study **Helm**
2. Keep **app + Argo CD** config in one Git repo
3. Install the app with **Argo CD + Helm** on Kind (`dev-cluster`)

Remote: [anilkumarsingh-pml/Nginx-Assignment-argocd](https://github.com/anilkumarsingh-pml/Nginx-Assignment-argocd)

Inspired by multi-env App-of-Apps layouts, scaled down to **one app** and **nonprod** so you can learn the pattern clearly.

## Learning path (read in order)

1. [docs/architecture/overview.md](docs/architecture/overview.md) — big picture
2. [docs/adr/0001-gitops-with-argocd-and-helm.md](docs/adr/0001-gitops-with-argocd-and-helm.md) — why Helm + Argo
3. [docs/adr/0002-app-of-apps-pattern.md](docs/adr/0002-app-of-apps-pattern.md) — why a root app
4. [docs/onboarding/local-kind-gitops.md](docs/onboarding/local-kind-gitops.md) — hands-on commands
5. [AGENTS.md](AGENTS.md) — how to work in this repo (humans + agents)

## Repository layout

```text
app/                         Application (HTML + Dockerfile)
charts/nginx-app/            Helm chart (Deployment + Service)
argocd/nonprod/
  app-of-apps/root.yaml      Bootstrap root Application
  app-projects/              AppProject guardrails
  applications/              Child Application (Helm)
docs/                        Architecture, onboarding, ADRs
REPORT.md                    Earlier rolling-update assignment notes
```

## Quick deploy (Kind `dev-cluster`)

Prerequisites: Colima/Docker, Kind cluster `dev-cluster`, Argo CD in namespace `argocd`, `kubectl` context `kind-dev-cluster`.

```bash
export PATH="$HOME/.local/bin:$PATH"
kubectl config use-context kind-dev-cluster

# 1) Build image (from app/ context)
docker build --build-arg VERSION=v1 -t nginx-app:v1 app/

# 2) Make image visible to Kind (no registry)
kind load docker-image nginx-app:v1 --name dev-cluster

# 3) Ensure latest manifests are on GitHub
git push origin HEAD

# 4) Bootstrap App-of-Apps (once)
kubectl apply -f argocd/nonprod/app-of-apps/root.yaml

# 5) Verify
kubectl -n argocd get applications
kubectl -n nginx-app get deploy,pods,svc -o wide
kubectl -n nginx-app port-forward svc/nginx-app 8080:80
# http://localhost:8080 → "NGINX Application — Version 1"
```

### Argo CD UI on localhost

```bash
kubectl config use-context kind-dev-cluster
kubectl -n argocd port-forward svc/argocd-server 8443:443
```

Open **https://localhost:8443** (accept the self-signed cert warning).

- Username: `admin`
- Password: from the initial secret:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

In the UI you should see Applications `nginx-gitops-root` and `nginx-app` as **Synced / Healthy**.

### Helm study (local, optional CLI)

```bash
# Install helm if needed, then:
helm lint charts/nginx-app
helm template nginx-app charts/nginx-app -f charts/nginx-app/values-nonprod.yaml
```

Change `replicaCount` in `charts/nginx-app/values-nonprod.yaml`, push, and watch Argo CD sync — that is the core GitOps loop.

## Private GitHub repo

If Argo CD cannot clone the repo, create a repository secret in `argocd` (PAT or SSH). Steps are in [docs/onboarding/local-kind-gitops.md](docs/onboarding/local-kind-gitops.md). Never commit credentials.

## Image access

Pods use `image: nginx-app:v1` with `imagePullPolicy: IfNotPresent`. If you see pull errors, re-run `kind load`. This lab does not use a remote registry.

## Earlier assignment

Rolling updates, scaling, and report answers remain in [REPORT.md](REPORT.md).
