# ADR 0001: GitOps with Argo CD and Helm

## Status

Accepted

## Context

Desired state in Git, continuous reconciliation, and clear separation between nonprod and prod.

## Decision

Argo CD reconciles; Helm packages bootstrap, app-of-apps, and workloads. GitHub is source of truth. Two Kind clusters, each with its own Argo CD.

## Consequences

Drift is healed. Changes require Git push. Two UIs when port-forwarding both clusters.
