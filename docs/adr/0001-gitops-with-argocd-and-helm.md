# ADR 0001: GitOps with Argo CD and Helm

## Status

Accepted

## Context

We need a learning path that mirrors production: desired state in Git, continuous reconciliation, and parameterized deploys per environment (nonprod vs prod).

## Decision

- **Argo CD** reconciles cluster state from Git.
- **Helm** packages workloads (`charts/webapp`) and environment bootstrap (`bootstrapping_*`).
- **GitHub** (`Nginx-Assignment-argocd`) is the source of truth.
- **Two Kind clusters**, each with its own Argo CD, model env isolation.

## Consequences

- Drift from `kubectl edit` is reverted by `selfHeal`.
- Chart/values changes take effect only after a Git push (and Argo sync).
- Operators use two Argo CD UIs (one per cluster), matching separate control planes.
