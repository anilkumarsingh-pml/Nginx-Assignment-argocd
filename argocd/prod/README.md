# Argo CD prod (learning stub)

Mirrors `argocd/nonprod` so you practice **environment parity** (same pattern as platform repos with `bootstrapping_prod` + `prod/`).

| Path | Purpose |
|------|---------|
| `app-of-apps/root.yaml` | Prod root Application — **not** applied on Kind by default |
| `applications/bootstrapping-prod.yaml` | Helm `bootstrapping_prod/` |
| `applications/nginx-app.yaml` | App chart with `values-prod.yaml` → namespace `nginx-app-prod` |

## Kind lab

Only apply nonprod:

```bash
kubectl apply -f argocd/nonprod/app-of-apps/root.yaml
```

Optional (creates prod AppProject + second nginx Deployment):

```bash
kubectl apply -f argocd/prod/app-of-apps/root.yaml
```

Use that only when you want to see two environments side by side on the same Kind cluster.
