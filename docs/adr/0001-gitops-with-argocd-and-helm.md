# ADR 0001: GitOps with Argo CD and Helm

## Status

Accepted

## Context

We need a learning path that mirrors production: desired state in Git, continuous reconciliation, parameterized deploys per environment.

## Decision

Use Argo CD for reconciliation and Helm for packaging workloads and environment bootstrap. GitHub is the source of truth.

## Consequences

Cluster drift is reverted by `selfHeal`. Chart/values changes require a Git push to take effect.
