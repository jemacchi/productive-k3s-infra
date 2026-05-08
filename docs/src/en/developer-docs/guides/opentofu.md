# OpenTofu Usage

`OpenTofu` is used in this repository for infrastructure provisioning concerns, not for cluster bootstrap logic.

## Where it is used today

- `scenarios/multipass/opentofu/`: creates the local VM topology used by the Multipass flow
- `scenarios/aws-single-node/opentofu/`: provisions the public AWS single-node infrastructure

## What OpenTofu is responsible for

- machine creation
- provider-level networking inputs
- instance metadata and outputs
- values that become part of `generated/cluster.json`

## What OpenTofu is not responsible for here

- SSH-side bootstrap orchestration
- Productive K3S mode sequencing
- validation of the final cluster stack

Those concerns stay in the scenario scripts or in the shared remote layer.

## Repository-level module space

The top-level `opentofu/modules/` directory is reserved for reusable infrastructure building blocks.

Current repository notes already make the distinction explicit:

- public reusable remote bootstrap logic already exists under `ansible/roles/remote_cluster`
- top-level reusable OpenTofu modules are still more of a forward-looking structure than the main reuse path for the implemented public scenarios

## Development guidance

When editing an OpenTofu-backed scenario:

- keep outputs aligned with what the refresh scripts expect
- preserve the generated metadata shape used by `status`, tests, and follow-up scripts
- keep provider-specific logic inside the scenario unless it clearly belongs in a shared module
