# ADR 0003: Environment bootstrap charts

## Status

Accepted

## Context

Prod and nonprod need the same platform primitives (tenant project, namespaces, app onboarding) with different scale and naming.

## Decision

Keep separate Helm charts:

- `bootstrapping_nonprod` → AppProject `platform-nonprod`
- `bootstrapping_prod` → AppProject `platform-prod`

Workload scale differs via `charts/webapp/values-nonprod.yaml` (`replicaCount: 1`) and `values-prod.yaml` (`replicaCount: 2`).

## Consequences

- Clear env parity for demos and learning.
- Chart templates stay parallel; values and project names diverge safely.
- Single tenant per environment (no multi-team AppProjects in this lab).
