# ADR 0004: Helm-generated Application CRs

## Status

Accepted

## Context

Hand-written Application YAML drifts between envs.

## Decision

- Bootstrap templates Applications from `deployments:`
- Apps App-of-Apps templates Applications from `applications:`
- AppProjects live as raw YAML under `infra-manifests/app-projects/`

## Consequences

Onboarding is values-driven. No `argocd/*/applications/*.yaml` workload files.
