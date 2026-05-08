# Reasons Behind `productive-k3s-infra`

`productive-k3s-infra` exists because `productive-k3s-core` and infrastructure orchestration solve different problems.

## Why not stop at `productive-k3s-core`

`productive-k3s-core` is the bootstrap contract for installing and validating a K3S-based stack.

That is enough when:

- one host already exists
- the operator can work directly on that machine
- the cluster topology is simple enough to assemble by hand

It is not enough when you also need to standardize:

- how machines are provisioned
- how node roles are declared
- how inventories and hostnames are rendered
- how multi-node bootstrap steps are sequenced
- how infrastructure-specific validation should run

## Why scenarios are the public entry point

This repository is intentionally centered on `scenarios/` instead of generic snippets.

The design goal is to provide deployment paths that are:

- reusable
- evaluable
- explicit
- close to what a team would actually run

That is why the public entry points are things like:

- local Multipass clusters
- on-premises SSH bootstrap
- a basic AWS single-node path

instead of a collection of disconnected helper fragments.

## Why keep shared layers underneath

Even though the public interface is scenario driven, the implementation still needs reuse boundaries.

The repository therefore keeps shared logic in layers such as:

- `ansible/roles/remote_cluster` for SSH-side bootstrap and validation
- `opentofu/` for infrastructure provisioning concerns
- `tests/` for static, contract, and live validation

That split makes it easier to evolve one public path without copy-pasting everything into every other path.

## Why the explicit mode split matters

The `server`, `agent`, `stack`, and `single-node` modes exposed by `productive-k3s-core` are what make infrastructure orchestration realistic.

They let this repository:

1. create or target machines first
2. assemble the cluster second
3. install the shared stack last

Without that split, infrastructure automation would have to fight a more monolithic bootstrap flow.

## Overall rationale

Taken together, the repository is meant to sit between raw infrastructure scripting and a fully productized private platform.

It aims to provide:

- infrastructure flows that are still public and understandable
- scenarios that are more realistic than toy examples
- a stable bridge into real multi-node or remote K3S environments

## See also

- [Product overview](index.md)
- [How to use Productive K3S Infra](how-to-use.md)
- [Relationship with Productive K3S Core](productive-k3s-relationship.md)
