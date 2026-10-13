# Argo CD prod (learning stub)

Mirrors `argocd/nonprod` so you practice **environment parity** (same pattern as platform repos with `bootstrapping_prod` + `prod/`).

| Path | Purpose |
|------|---------|
| `app-of-apps/root.yaml` | Prod root Application — **not** applied on Kind by default |
| `applications/bootstrapping-prod.yaml` | Helm `bootstrapping_prod/` |
| `applications/nginx-app.yaml` | App chart with `values-prod.yaml` → namespace `nginx-app-prod` |

## Kind lab

**Use nonprod only** on `dev-cluster`:

```bash
kubectl apply -f argocd/nonprod/app-of-apps/root.yaml
```

Do **not** apply this prod root on the Kind learning cluster.  
`argocd/prod` + `bootstrapping_prod` exist for **structure / learning parity** (how a second environment would look in Git).

A second Kind cluster for prod was attempted but skipped: Argo CD images could not be pulled/loaded reliably in this network environment. In a real company setup you would have separate nonprod and prod clusters (or accounts), each with its own Argo CD (or one hub Argo managing both).
