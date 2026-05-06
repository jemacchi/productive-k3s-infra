# Open Vs Pro

This repository is the public/open foundation. It should maximize reuse, evaluation, and clarity.

## Public scope

The public repository is the place for:

- local Multipass-based environments
- basic public AWS single-node provisioning
- basic on-premises bootstrap over `SSH`
- generic `OpenTofu` building blocks
- generic `Ansible` and shell-based remote bootstrap logic
- test contracts, matrix orchestration, and anonymous run artifacts
- documentation that explains how the public paths work

## Pro or private scope

Commercial or private extensions can live above this baseline when they require more customer-specific behavior, for example:

- HA cloud clusters
- hardened network policies and private topologies
- managed inventories and tenant-specific compositions
- automated upgrades and rollback flows
- backup and restore workflows
- richer validation packs and packaged app stacks

## Why keep the line explicit

The open repository should stay understandable and broadly reusable.

That means the public code should prefer:

- generic assumptions
- documented operator inputs
- explicit `Makefile` entry points
- reusable layers that are not tied to a single customer environment

## Notes

!!! note
    "Pro" is a boundary of scope, not a signal that the open repository is incomplete. The open repository should still provide real, working use cases.

!!! note
    Public use cases are intentionally simple in several places. Simplicity is often part of the public product positioning, not necessarily a missing feature.
