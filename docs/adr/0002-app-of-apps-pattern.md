# ADR 0002: App-of-Apps pattern

## Status

Accepted

## Context

Managing many Applications imperatively does not scale and hides the bootstrap order.

## Decision

A root Application per environment points at the bootstrap Helm chart. The chart generates child Application CRs (wave 1) after AppProject/namespaces (wave 0).

## Consequences

Applying one root YAML bootstraps the whole env. Child apps are pruned when removed from bootstrap values.
