# ADR 0002: App-of-Apps pattern

## Status

Accepted

## Context

Imperative Application sprawl hides bootstrap order.

## Decision

Layered App-of-Apps: deployable root → bootstrap Helm (`deployments[]`) → apps App-of-Apps (`applications[]`) → workload charts.

## Consequences

One apply bootstraps an env. Removing a layer or app from values prunes children when prune is enabled.
