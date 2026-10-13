# ADR 0003: Environment bootstrap charts

## Status

Accepted

## Context

Prod and nonprod need the same platform primitives (project, namespaces, app onboarding) with different scale/settings.

## Decision

Keep separate Helm charts `bootstrapping_nonprod` and `bootstrapping_prod` with parallel structure and env-specific values (replicas via `values-nonprod.yaml` / `values-prod.yaml` on the webapp chart).

## Consequences

Clear parity for learning. Shared logic is duplicated lightly on purpose so each env chart can diverge safely.
