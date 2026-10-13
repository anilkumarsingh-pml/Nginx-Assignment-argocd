# Argo CD nonprod (learning)

| Path | What it is |
|------|------------|
| `app-of-apps/root.yaml` | Bootstrap root Application (apply with `kubectl` once on Kind) |
| `applications/bootstrapping-nonprod.yaml` | Env bootstrap Helm chart (AppProject + Namespaces) |
| `applications/nginx-app.yaml` | Sample app → namespace `nginx-app` |
| `applications/catalog-ui.yaml` | Sample app → namespace `catalog-ui` |
| `applications/payments-api.yaml` | Sample app → namespace `payments-api` |
| `applications/ops-portal.yaml` | Sample app → namespace `ops-portal` |

## Sync order (why)

1. **Root** creates all child Application CRs from Git (App-of-Apps).
2. **bootstrapping-nonprod** (wave 0) installs AppProject + namespaces.
3. **Workload apps** (wave 1) each render the same `charts/nginx-app` chart with **different value files** into their own namespace.

That is the production feeling: one root → many Applications → many teams/services, still one Git repo.

## Same chart, many apps (learning tip)

All four workloads intentionally reuse `charts/nginx-app` + local image `nginx-app:v1`. In real platforms each app often has its own chart/image; the **Argo Application list** and **namespace isolation** are what you are practicing here.
