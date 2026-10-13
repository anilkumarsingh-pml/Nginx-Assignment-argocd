# Argo CD nonprod (learning)

| Path | What it is |
|------|------------|
| `app-of-apps/root.yaml` | Bootstrap root Application (apply with `kubectl` once on Kind) |
| `applications/bootstrapping-nonprod.yaml` | Syncs Helm chart `bootstrapping_nonprod/` (AppProject + Namespace) |
| `applications/nginx-app.yaml` | Syncs app Helm chart `charts/nginx-app` with `values-nonprod.yaml` |

## Sync order (why)

1. **Root** creates the child Application CRs from Git.
2. **bootstrapping-nonprod** (wave 0) installs environment guardrails via Helm.
3. **nginx-app** (wave 1) deploys the workload into `nginx-app`.

This mirrors platform layouts that separate **environment bootstrap** from **application charts**.
