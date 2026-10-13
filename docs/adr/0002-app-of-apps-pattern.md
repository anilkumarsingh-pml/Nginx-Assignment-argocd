# ADR 0002: App-of-Apps pattern

## Status

Accepted (learning lab)

## Context

We could `kubectl apply` a single Application for the NGINX chart. Larger platforms (and training inspiration layouts) use a **root Application** that syncs many child Applications and AppProjects from Git.

## Decision

Use a minimal App-of-Apps:

1. **Root** `nginx-gitops-root` — applied once with `kubectl`; syncs `argocd/nonprod` (excluding `app-of-apps/`).
2. **AppProject** `learning-nonprod` — limits allowed repos/namespaces.
3. **Child** `nginx-app` — Helm Application for the chart.

Sync waves: AppProject (`0`) before Applications (`1`).

## Consequences

**Positive**

- Same bootstrap habit used in multi-service GitOps repos.
- Adding another learning app later = add YAML under `applications/` and push.
- AppProject teaches least-privilege destinations.

**Trade-offs**

- Slightly more YAML than a single Application.
- Root is bootstrapped out-of-band (by design) so it does not manage itself.
