# ADR 0003: Environment bootstrap Helm charts

## Status

Accepted (learning lab)

## Context

Platform GitOps repos (e.g. layouts with `bootstrapping_nonprod` / `bootstrapping_prod`) separate **environment bootstrap** from **application charts**. Bootstrap installs shared guardrails (AppProjects, namespaces) before workloads sync.

## Decision

1. Add Helm charts:
   - `bootstrapping_nonprod/` — AppProject `learning-nonprod` + Namespace `nginx-app`
   - `bootstrapping_prod/` — AppProject `learning-prod` + Namespace `nginx-app-prod` (parity stub)
2. Wire them via Argo Applications under `argocd/nonprod/applications/` and `argocd/prod/applications/`.
3. Keep Kind bootstrap as **nonprod only**: `kubectl apply -f argocd/nonprod/app-of-apps/root.yaml`.
4. Remove the static `app-projects/*.yaml` file; AppProject is rendered by the bootstrap chart (single source of truth).

## Consequences

**Positive**

- Matches the assignment inspiration structure (bootstrap charts + env folders).
- Teaches sync order: bootstrap (wave 0) → app (wave 1).
- Prod stub shows how a second environment would look without requiring a second cluster.

**Trade-offs**

- Slightly more moving parts than a lone Application.
- Prod root must not be applied accidentally on Kind unless you want a second nginx Deployment.
