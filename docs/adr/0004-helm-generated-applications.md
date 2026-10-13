# ADR 0004: Helm-generated Application CRs in bootstrap charts

## Status

Accepted

## Context

Hand-written Argo CD Application manifests under `argocd/*/applications/` duplicate fields and drift between nonprod and prod.

## Decision

Bootstrap charts template from `values.yaml` → `applications:`:

1. AppProject (single tenant)
2. Target namespaces
3. One `Application` CR per app (Helm `valueFiles` for app + env overlays)

Do **not** add per-app Application YAML files under `argocd/`. Roots point only at the bootstrap chart path.

## Consequences

- Onboarding is: `apps/<name>/` + `values-<name>.yaml` + bootstrap values entry + image load + Git push.
- Nonprod/prod stay structurally parallel; only overlays and project names differ.
