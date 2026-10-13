# Argo CD nonprod (learning)

| Path | What it is |
|------|------------|
| `app-of-apps/root.yaml` | Bootstrap root Application (apply with `kubectl` once) |
| `app-projects/` | AppProject guardrails |
| `applications/` | Child apps (Helm chart for nginx-app) |

Flow: push Git → apply root → Argo creates AppProject + `nginx-app` Application → Helm chart syncs to namespace `nginx-app`.
