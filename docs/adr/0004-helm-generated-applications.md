# ADR 0004: Helm-generated Application CRs in bootstrap charts

## Status

Accepted

## Context

Hand-written Argo CD Application manifests per app under `argocd/*/applications/` duplicate fields and drift between nonprod and prod.

## Decision

Environment bootstrap Helm charts (`bootstrapping_nonprod`, `bootstrapping_prod`) template:

1. AppProject (single tenant)
2. Target namespaces
3. One `Application` CR per entry in `values.yaml` → `applications`

Root App-of-Apps points only at the bootstrap chart path.

## Consequences

- Onboarding a service is a values + chart overlay change, not a new Application YAML file.
- Nonprod/prod stay structurally parallel; only env overlays and project names differ.
