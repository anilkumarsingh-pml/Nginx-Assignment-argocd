# ADR 0002: App-of-Apps pattern

## Status

Accepted

## Context

Managing many Applications imperatively does not scale and hides bootstrap order (project/namespaces before workloads).

## Decision

A **root Application** per environment (`root-nonprod` / `root-prod`) points at the matching bootstrap Helm chart. The chart renders:

- Wave 0: AppProject + namespaces
- Wave 1: child Application CRs for each onboarded app

Roots live under `argocd/{nonprod|prod}/app-of-apps/` and are applied once with `kubectl apply`.

## Consequences

- Applying one root YAML bootstraps the whole environment.
- Removing an app from bootstrap `applications:` prunes its Application (and workloads) when prune is enabled.
