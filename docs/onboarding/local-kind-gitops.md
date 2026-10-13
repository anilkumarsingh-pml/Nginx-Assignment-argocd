# Onboarding: local Kind GitOps

## Prerequisites

- Docker / Colima running
- Kind cluster named `dev-cluster` (kubectl context `kind-dev-cluster`)
- Argo CD already installed in namespace `argocd`
- `kubectl` on your `PATH`
- Access to push to [Nginx-Assignment-argocd](https://github.com/anilkumarsingh-pml/Nginx-Assignment-argocd)

Optional: install Helm CLI to lint/template charts locally.

## 1. Clone / use this repo

```bash
cd /path/to/Nginx-K8s-Deployment-Assignment
git remote -v   # should include origin → Nginx-Assignment-argocd.git
```

## 2. Build the image and load into Kind

There is **no container registry** in this lab. Kind only sees images you load:

```bash
docker build --build-arg VERSION=v1 -t nginx-app:v1 app/
kind load docker-image nginx-app:v1 --name dev-cluster
```

## 3. Push Git (Argo CD reads GitHub, not your laptop disk)

```bash
git add .
git commit -m "Describe your change"
git push -u origin HEAD
```

If the repository is **private**, register credentials in Argo CD before sync will work:

```bash
kubectl -n argocd create secret generic repo-nginx-assignment-argocd \
  --from-literal=type=git \
  --from-literal=url=https://github.com/anilkumarsingh-pml/Nginx-Assignment-argocd.git \
  --from-literal=username='YOUR_GITHUB_USER' \
  --from-literal=password='YOUR_GITHUB_PAT' \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n argocd label secret repo-nginx-assignment-argocd \
  argocd.argoproj.io/secret-type=repository
```

Do **not** commit the PAT into this repo.

## 4. Bootstrap App-of-Apps

```bash
kubectl config use-context kind-dev-cluster
kubectl apply -f argocd/nonprod/app-of-apps/root.yaml
```

This creates Application `nginx-gitops-root`, which syncs:

- `AppProject/learning-nonprod`
- `Application/nginx-app` (Helm → namespace `nginx-app`)

## 5. Verify

```bash
kubectl -n argocd get applications
kubectl -n argocd get appprojects
kubectl -n nginx-app get deploy,pods,svc -o wide

kubectl -n nginx-app port-forward svc/nginx-app 8080:80
# Open http://localhost:8080 → "NGINX Application — Version 1"
```

## 6. Practice a GitOps change

```bash
# Edit charts/nginx-app/values-nonprod.yaml → replicaCount: 3
git commit -am "Scale nonprod to 3 replicas"
git push
# Watch Argo self-heal / sync
kubectl -n argocd get application nginx-app -w
kubectl -n nginx-app get pods -w
```

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Application `Unknown` / repo error | Private repo / bad URL | Add repo secret; check `repoURL` |
| `ImagePullBackOff` | Image not on Kind node | Re-run `kind load` |
| Drift comes back | `selfHeal: true` | Change Git, not only the live cluster |
| Empty `nginx-app` namespace | Child app not synced | `kubectl -n argocd describe application nginx-app` |
