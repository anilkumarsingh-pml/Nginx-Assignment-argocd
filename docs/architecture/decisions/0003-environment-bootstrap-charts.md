# ADR 0003: Environment bootstrap charts

## Status

Accepted

## Context

Nonprod and prod need parallel platform entrypoints with different scale.

## Decision

`platform/bootstrapping_nonprod` and `platform/bootstrapping_prod` list the same layer names; env trees under `platform/{nonprod,prod}/project-platform/` diverge (AppProject name, valueFiles). Workload replicas via `values-nonprod.yaml` / `values-prod.yaml`.

## Consequences

Clear parity with PML bootstrap naming. One tenant only.
